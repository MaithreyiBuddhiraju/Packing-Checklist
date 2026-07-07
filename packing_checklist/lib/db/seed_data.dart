// Seed data carried over from the original web app (packing-app/index.html).
// Numbered duplicates ("jacket #1/#2") are collapsed into quantities; the
// SF/LA/Both location markers become freeform, editable tags.

class SeedItem {
  final String name;
  final int qty;
  final String? tag;
  const SeedItem(this.name, {this.qty = 1, this.tag});
}

class SeedCategory {
  final String name;
  final String emoji;
  final List<SeedItem> items;
  const SeedCategory(this.name, this.emoji, this.items);
}

const List<SeedCategory> seedCategories = [
  SeedCategory('Layers & Outerwear', '🧥', [
    SeedItem('Lightweight jacket', qty: 2, tag: 'Both'),
    SeedItem('Light cardigan', qty: 2, tag: 'Both'),
    SeedItem('Long-sleeve lightweight sweater', tag: 'SF'),
  ]),
  SeedCategory('Tops', '👚', [
    SeedItem('Lightweight blouse or tee', qty: 3, tag: 'Both'),
    SeedItem('Nicer blouse for evenings out', tag: 'Both'),
    SeedItem('Casual long-sleeve top', tag: 'SF'),
  ]),
  SeedCategory('Bottoms', '👖', [
    SeedItem('Jeans', qty: 2, tag: 'SF'),
    SeedItem('Light pants or casual shorts', tag: 'LA'),
  ]),
  SeedCategory('Dresses', '👗', [
    SeedItem('Summer dress', qty: 2, tag: 'Both'),
  ]),
  SeedCategory('Shoes', '👟', [
    SeedItem('Comfortable walking shoes / sneakers', tag: 'Both'),
    SeedItem('Sandals or slip-ons', tag: 'LA'),
    SeedItem('Dressier flats or low heels', tag: 'Both'),
  ]),
  SeedCategory('Accessories', '🕶️', [
    SeedItem('Sunglasses', tag: 'Both'),
    SeedItem('Light scarf or wrap', tag: 'SF'),
    SeedItem('Day bag / crossbody', tag: 'Both'),
    SeedItem('Small evening clutch', tag: 'Both'),
    SeedItem('Sun hat or cap', tag: 'LA'),
  ]),
  SeedCategory('Sleepwear & Undergarments', '😴', [
    SeedItem('Pajamas / sleepwear', qty: 2, tag: 'Both'),
    SeedItem('Underwear', qty: 11, tag: 'Both'),
    SeedItem('Regular bra', qty: 2, tag: 'Both'),
    SeedItem('Strapless or convertible bra', tag: 'Both'),
    SeedItem('Socks', qty: 6, tag: 'Both'),
  ]),
  SeedCategory('Toiletries & Skincare', '🧴', [
    SeedItem('SPF 50 sunscreen', tag: 'Both'),
    SeedItem('SPF lip balm', tag: 'Both'),
    SeedItem('Travel-size skincare routine', tag: 'Both'),
    SeedItem('Foundation', tag: 'Both'),
    SeedItem('Full makeup essentials kit', tag: 'Both'),
    SeedItem('Travel toiletries kit', tag: 'Both'),
  ]),
  SeedCategory('Electronics & Extras', '🔌', [
    SeedItem('Phone charger', tag: 'Both'),
    SeedItem('Laptop + charger', tag: 'SF'),
    SeedItem('Dyson Airwrap — carry-on only', tag: 'Both'),
    SeedItem('Earbuds / headphones', tag: 'Both'),
    SeedItem('Portable power bank', tag: 'Both'),
    SeedItem('Books or e-reader', tag: 'Both'),
    SeedItem('Reusable water bottle', tag: 'Both'),
    SeedItem('Small first-aid kit', tag: 'Both'),
    SeedItem('Road trip snacks', tag: 'LA'),
  ]),
];
