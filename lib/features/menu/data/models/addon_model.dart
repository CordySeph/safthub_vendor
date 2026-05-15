class AddonItem {
  final String id;
  final String name;
  final double price;
  final bool isAvailable;

  AddonItem({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
  });

  factory AddonItem.fromJson(Map<String, dynamic> json) {
    return AddonItem(
      id: json['id'] ?? json['ID'] ?? '',
      name: json['name'] ?? json['Name'] ?? '',
      price: (json['price'] ?? json['Price'] ?? 0).toDouble(),
      isAvailable: json['is_available'] ?? json['IsAvailable'] ?? true,
    );
  }
}

class AddonGroup {
  final String id;
  final String name;
  final String description;
  final int minSelection;
  final int maxSelection;
  final List<AddonItem> items;

  AddonGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.minSelection,
    required this.maxSelection,
    required this.items,
  });

  factory AddonGroup.fromJson(Map<String, dynamic> json) {
    return AddonGroup(
      id: json['id'] ?? json['ID'] ?? '',
      name: json['name'] ?? json['Name'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
      minSelection: json['min_selection'] ?? json['MinSelection'] ?? 0,
      maxSelection: json['max_selection'] ?? json['MaxSelection'] ?? 1,
      items: (json['addon_items'] ?? json['AddonItems'] as List?)
              ?.map((i) => AddonItem.fromJson(i))
              .toList() ??
          [],
    );
  }
}
