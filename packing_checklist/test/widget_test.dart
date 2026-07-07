import 'package:flutter_test/flutter_test.dart';
import 'package:packing_checklist/models/category.dart';
import 'package:packing_checklist/models/item.dart';

void main() {
  test('Category packed counts', () {
    final cat = Category(id: 1, name: 'Tops', sortOrder: 0, items: [
      Item(id: 1, categoryId: 1, name: 'Tee', packed: true, sortOrder: 0),
      Item(id: 2, categoryId: 1, name: 'Blouse', sortOrder: 1),
    ]);
    expect(cat.packedCount, 1);
    expect(cat.allPacked, false);
    cat.items[1].packed = true;
    expect(cat.allPacked, true);
  });

  test('Item round-trips through map', () {
    final item = Item(
        id: 7,
        categoryId: 3,
        name: 'Socks',
        quantity: 6,
        sortOrder: 2,
        tag: 'Both');
    final back = Item.fromMap(item.toMap());
    expect(back.name, 'Socks');
    expect(back.quantity, 6);
    expect(back.tag, 'Both');
    expect(back.packed, false);
  });
}
