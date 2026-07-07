import 'item.dart';

class Category {
  final int id;
  String name;
  String emoji;
  int sortOrder;
  bool collapsed;
  final List<Item> items;

  Category({
    required this.id,
    required this.name,
    this.emoji = '📦',
    required this.sortOrder,
    this.collapsed = false,
    List<Item>? items,
  }) : items = items ?? [];

  int get packedCount => items.where((i) => i.packed).length;
  bool get allPacked => items.isNotEmpty && packedCount == items.length;

  factory Category.fromMap(Map<String, Object?> m) => Category(
        id: m['id'] as int,
        name: m['name'] as String,
        emoji: m['emoji'] as String,
        sortOrder: m['sort_order'] as int,
        collapsed: (m['collapsed'] as int) != 0,
      );
}
