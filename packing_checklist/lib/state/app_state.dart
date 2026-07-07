import 'package:flutter/foundation.dart' hide Category;

import '../db/database_helper.dart';
import '../models/category.dart';
import '../models/item.dart';

/// Single source of truth for the checklist. Every mutation persists to
/// SQLite first, then updates the in-memory list and notifies listeners.
class AppState extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Category> categories = [];
  bool loaded = false;
  String tripName = '';

  int get totalItems => categories.fold(0, (s, c) => s + c.items.length);
  int get packedItems => categories.fold(0, (s, c) => s + c.packedCount);
  double get progress => totalItems == 0 ? 0 : packedItems / totalItems;

  Future<void> load() async {
    categories = await _db.loadAll();
    tripName = await _db.getTripName();
    loaded = true;
    notifyListeners();
  }

  Future<void> setTripName(String name) async {
    tripName = name.trim();
    await _db.setTripName(tripName);
    notifyListeners();
  }

  // ── Items ─────────────────────────────────────────────────────────

  Future<void> togglePacked(Item item) async {
    item.packed = !item.packed;
    await _db.updateItem(item);
    notifyListeners();
  }

  Future<void> setQuantity(Item item, int quantity) async {
    if (quantity < 1) return;
    item.quantity = quantity;
    await _db.updateItem(item);
    notifyListeners();
  }

  Future<void> addItem(Category cat, String name, int quantity, String? tag) async {
    final item = Item(
      id: 0,
      categoryId: cat.id,
      name: name,
      quantity: quantity,
      sortOrder: cat.items.length,
      tag: tag,
    );
    final id = await _db.insertItem(item);
    cat.items.add(Item(
      id: id,
      categoryId: cat.id,
      name: name,
      quantity: quantity,
      sortOrder: item.sortOrder,
      tag: tag,
    ));
    notifyListeners();
  }

  Future<void> editItem(Item item, String name, int quantity, String? tag) async {
    item.name = name;
    item.quantity = quantity < 1 ? 1 : quantity;
    item.tag = (tag == null || tag.trim().isEmpty) ? null : tag.trim();
    await _db.updateItem(item);
    notifyListeners();
  }

  Future<void> deleteItem(Item item) async {
    await _db.deleteItem(item.id);
    final cat = _categoryOf(item);
    cat?.items.remove(item);
    notifyListeners();
  }

  /// Undo for [deleteItem]: reinserts the item (same id) at its old position.
  Future<void> restoreItem(Item item) async {
    final cat = _categoryOf(item);
    if (cat == null) return; // category was deleted meanwhile
    await _db.insertItem(item, keepId: true);
    final index = item.sortOrder.clamp(0, cat.items.length);
    cat.items.insert(index, item);
    await _renumberItems(cat);
    notifyListeners();
  }

  // Index parameters follow onReorderItem semantics (newIndex pre-adjusted).
  Future<void> reorderItems(Category cat, int oldIndex, int newIndex) async {
    final item = cat.items.removeAt(oldIndex);
    cat.items.insert(newIndex, item);
    await _renumberItems(cat);
    notifyListeners();
  }

  Future<void> _renumberItems(Category cat) async {
    for (var i = 0; i < cat.items.length; i++) {
      cat.items[i].sortOrder = i;
    }
    await _db.updateItemOrder(cat.items);
  }

  Category? _categoryOf(Item item) {
    for (final c in categories) {
      if (c.id == item.categoryId) return c;
    }
    return null;
  }

  // ── Categories ────────────────────────────────────────────────────

  Future<void> addCategory(String name, String emoji) async {
    final id = await _db.insertCategory(name, emoji, categories.length);
    categories.add(Category(
        id: id, name: name, emoji: emoji, sortOrder: categories.length));
    notifyListeners();
  }

  Future<void> editCategory(Category cat, String name, String emoji) async {
    cat.name = name;
    cat.emoji = emoji;
    await _db.updateCategory(cat);
    notifyListeners();
  }

  Future<void> deleteCategory(Category cat) async {
    await _db.deleteCategory(cat.id); // items cascade
    categories.remove(cat);
    notifyListeners();
  }

  Future<void> toggleCollapsed(Category cat) async {
    cat.collapsed = !cat.collapsed;
    await _db.updateCategory(cat);
    notifyListeners();
  }

  bool get allCollapsed =>
      categories.isNotEmpty && categories.every((c) => c.collapsed);

  Future<void> toggleCollapseAll() async {
    final collapse = !allCollapsed;
    await _db.setAllCollapsed(collapse);
    for (final c in categories) {
      c.collapsed = collapse;
    }
    notifyListeners();
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    final cat = categories.removeAt(oldIndex);
    categories.insert(newIndex, cat);
    for (var i = 0; i < categories.length; i++) {
      categories[i].sortOrder = i;
    }
    await _db.updateCategoryOrder(categories);
    notifyListeners();
  }

  // ── Bulk / template ───────────────────────────────────────────────

  Future<void> uncheckAll() async {
    await _db.uncheckAll();
    for (final c in categories) {
      for (final i in c.items) {
        i.packed = false;
      }
    }
    notifyListeners();
  }

  Future<void> saveTemplate() => _db.saveTemplate();

  Future<void> resetFromTemplate() async {
    await _db.resetFromTemplate();
    await load();
  }
}
