class Item {
  final int id;
  int categoryId;
  String name;
  int quantity;
  bool packed;
  int sortOrder;
  String? tag;

  Item({
    required this.id,
    required this.categoryId,
    required this.name,
    this.quantity = 1,
    this.packed = false,
    required this.sortOrder,
    this.tag,
  });

  factory Item.fromMap(Map<String, Object?> m) => Item(
        id: m['id'] as int,
        categoryId: m['category_id'] as int,
        name: m['name'] as String,
        quantity: m['quantity'] as int,
        packed: (m['packed'] as int) != 0,
        sortOrder: m['sort_order'] as int,
        tag: m['tag'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'quantity': quantity,
        'packed': packed ? 1 : 0,
        'sort_order': sortOrder,
        'tag': tag,
      };
}
