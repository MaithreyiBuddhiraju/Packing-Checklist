// Seed data carried over from the original web app (packing-app/index.html).
// Numbered duplicates ("jacket #1/#2") are collapsed into quantities.
// Items ship untagged — tags are a freeform per-trip label the user adds.

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
    SeedItem('Lightweight jacket', qty: 2),
    SeedItem('Light cardigan', qty: 2),
    SeedItem('Long-sleeve lightweight sweater'),
  ]),
  SeedCategory('Tops', '👚', [
    SeedItem('Lightweight blouse or tee', qty: 3),
    SeedItem('Nicer blouse for evenings out'),
    SeedItem('Casual long-sleeve top'),
  ]),
  SeedCategory('Bottoms', '👖', [
    SeedItem('Jeans', qty: 2),
    SeedItem('Light pants or casual shorts'),
  ]),
  SeedCategory('Dresses', '👗', [
    SeedItem('Summer dress', qty: 2),
  ]),
  SeedCategory('Shoes', '👟', [
    SeedItem('Comfortable walking shoes / sneakers'),
    SeedItem('Sandals or slip-ons'),
    SeedItem('Dressier flats or low heels'),
  ]),
  SeedCategory('Accessories', '🕶️', [
    SeedItem('Sunglasses'),
    SeedItem('Light scarf or wrap'),
    SeedItem('Day bag / crossbody'),
    SeedItem('Small evening clutch'),
    SeedItem('Sun hat or cap'),
  ]),
  SeedCategory('Sleepwear & Undergarments', '😴', [
    SeedItem('Pajamas / sleepwear', qty: 2),
    SeedItem('Underwear', qty: 11),
    SeedItem('Regular bra', qty: 2),
    SeedItem('Strapless or convertible bra'),
    SeedItem('Socks', qty: 6),
  ]),
  SeedCategory('Toiletries & Skincare', '🧴', [
    SeedItem('SPF 50 sunscreen'),
    SeedItem('SPF lip balm'),
    SeedItem('Travel-size skincare routine'),
    SeedItem('Foundation'),
    SeedItem('Full makeup essentials kit'),
    SeedItem('Travel toiletries kit'),
  ]),
  SeedCategory('Electronics & Extras', '🔌', [
    SeedItem('Phone charger'),
    SeedItem('Laptop + charger'),
    SeedItem('Dyson Airwrap — carry-on only'),
    SeedItem('Earbuds / headphones'),
    SeedItem('Portable power bank'),
    SeedItem('Books or e-reader'),
    SeedItem('Reusable water bottle'),
    SeedItem('Small first-aid kit'),
    SeedItem('Road trip snacks'),
  ]),
];
