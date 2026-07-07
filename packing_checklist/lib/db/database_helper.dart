import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/category.dart';
import '../models/item.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'packing_checklist.db');
    return openDatabase(
      path,
      version: 2,
      // sqflite ships with foreign keys OFF; cascade deletes depend on this.
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // v1 seeded trip-specific SF/LA/Both tags; clear them everywhere.
          const where = "tag IN ('SF', 'LA', 'Both')";
          await db.update('items', {'tag': null}, where: where);
          await db.update('template_items', {'tag': null}, where: where);
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        emoji      TEXT    NOT NULL DEFAULT '📦',
        sort_order INTEGER NOT NULL,
        collapsed  INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE items (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
        name        TEXT    NOT NULL,
        quantity    INTEGER NOT NULL DEFAULT 1,
        packed      INTEGER NOT NULL DEFAULT 0,
        sort_order  INTEGER NOT NULL,
        tag         TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE template_categories (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        emoji      TEXT    NOT NULL DEFAULT '📦',
        sort_order INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE template_items (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL REFERENCES template_categories(id) ON DELETE CASCADE,
        name        TEXT    NOT NULL,
        quantity    INTEGER NOT NULL DEFAULT 1,
        sort_order  INTEGER NOT NULL,
        tag         TEXT
      )
    ''');

    // Seed the active checklist AND the template, so "Reset from template"
    // works before the user ever saves one. (onCreate already runs inside a
    // transaction — do not open a nested one here.)
    for (var c = 0; c < seedCategories.length; c++) {
      final cat = seedCategories[c];
      final catId = await db.insert('categories',
          {'name': cat.name, 'emoji': cat.emoji, 'sort_order': c});
      final tplCatId = await db.insert('template_categories',
          {'name': cat.name, 'emoji': cat.emoji, 'sort_order': c});
      for (var i = 0; i < cat.items.length; i++) {
        final it = cat.items[i];
        await db.insert('items', {
          'category_id': catId,
          'name': it.name,
          'quantity': it.qty,
          'packed': 0,
          'sort_order': i,
          'tag': it.tag,
        });
        await db.insert('template_items', {
          'category_id': tplCatId,
          'name': it.name,
          'quantity': it.qty,
          'sort_order': i,
          'tag': it.tag,
        });
      }
    }
  }

  // ── Load ──────────────────────────────────────────────────────────

  Future<List<Category>> loadAll() async {
    final db = await database;
    final catRows = await db.query('categories', orderBy: 'sort_order');
    final itemRows = await db.query('items', orderBy: 'sort_order');
    final cats = catRows.map(Category.fromMap).toList();
    final byId = {for (final c in cats) c.id: c};
    for (final row in itemRows) {
      final item = Item.fromMap(row);
      byId[item.categoryId]?.items.add(item);
    }
    return cats;
  }

  // ── Categories ────────────────────────────────────────────────────

  Future<int> insertCategory(String name, String emoji, int sortOrder) async {
    final db = await database;
    return db.insert(
        'categories', {'name': name, 'emoji': emoji, 'sort_order': sortOrder});
  }

  Future<void> updateCategory(Category c) async {
    final db = await database;
    await db.update(
      'categories',
      {'name': c.name, 'emoji': c.emoji, 'collapsed': c.collapsed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setAllCollapsed(bool collapsed) async {
    final db = await database;
    await db.update('categories', {'collapsed': collapsed ? 1 : 0});
  }

  Future<void> updateCategoryOrder(List<Category> cats) async {
    final db = await database;
    final batch = db.batch();
    for (var i = 0; i < cats.length; i++) {
      batch.update('categories', {'sort_order': i},
          where: 'id = ?', whereArgs: [cats[i].id]);
    }
    await batch.commit(noResult: true);
  }

  // ── Items ─────────────────────────────────────────────────────────

  /// Inserts [item]; when [keepId] is true the item's existing id is reused
  /// (used by undo-restore so references stay valid).
  Future<int> insertItem(Item item, {bool keepId = false}) async {
    final db = await database;
    final map = item.toMap();
    if (!keepId) map.remove('id');
    return db.insert('items', map);
  }

  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update('items', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateItemOrder(List<Item> items) async {
    final db = await database;
    final batch = db.batch();
    for (var i = 0; i < items.length; i++) {
      batch.update('items', {'sort_order': i},
          where: 'id = ?', whereArgs: [items[i].id]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> uncheckAll() async {
    final db = await database;
    await db.update('items', {'packed': 0});
  }

  // ── Template ──────────────────────────────────────────────────────

  /// Snapshots the active checklist (structure only, not packed state)
  /// into the template tables, replacing any previous template.
  Future<void> saveTemplate() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('template_items');
      await txn.delete('template_categories');
      final cats = await txn.query('categories', orderBy: 'sort_order');
      for (final c in cats) {
        final tplCatId = await txn.insert('template_categories', {
          'name': c['name'],
          'emoji': c['emoji'],
          'sort_order': c['sort_order'],
        });
        final items = await txn.query('items',
            where: 'category_id = ?', whereArgs: [c['id']],
            orderBy: 'sort_order');
        for (final it in items) {
          await txn.insert('template_items', {
            'category_id': tplCatId,
            'name': it['name'],
            'quantity': it['quantity'],
            'sort_order': it['sort_order'],
            'tag': it['tag'],
          });
        }
      }
    });
  }

  /// Replaces the active checklist with the template: template structure,
  /// everything unpacked.
  Future<void> resetFromTemplate() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('items');
      await txn.delete('categories');
      final cats = await txn.query('template_categories', orderBy: 'sort_order');
      for (final c in cats) {
        final catId = await txn.insert('categories', {
          'name': c['name'],
          'emoji': c['emoji'],
          'sort_order': c['sort_order'],
        });
        final items = await txn.query('template_items',
            where: 'category_id = ?', whereArgs: [c['id']],
            orderBy: 'sort_order');
        for (final it in items) {
          await txn.insert('items', {
            'category_id': catId,
            'name': it['name'],
            'quantity': it['quantity'],
            'packed': 0,
            'sort_order': it['sort_order'],
            'tag': it['tag'],
          });
        }
      }
    });
  }
}
