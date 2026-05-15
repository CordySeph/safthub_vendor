class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? categoryId;
  final bool isAvailable;
  final int stock;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.categoryId,
    required this.isAvailable,
    required this.stock,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    // Extract price and status from V2 or V1 structure
    double price = (json['price'] ?? 0).toDouble();
    bool isAvailable = true;
    int stock = 0;

    // V2 Status handling
    if (json['status'] != null && json['status'] is Map) {
      isAvailable = json['status']['is_available'] ?? true;
    }

    // V2 Stock handling
    if (json['stock'] != null && json['stock'] is Map) {
      stock = json['stock']['current_stock'] ?? 0;
    }

    // Legacy/V1 Variants fallback
    final variants = json['Variants'] as List?;
    if (variants != null && variants.isNotEmpty) {
      final firstVariant = variants.first;
      if (price == 0.0) price = (firstVariant['Price'] ?? 0).toDouble();
      isAvailable = firstVariant['IsAvailable'] ?? isAvailable;
      stock = firstVariant['Stock'] ?? stock;
    }

    return MenuItemModel(
      id: json['id'] ?? json['ID'] ?? '',
      name: json['name'] ?? json['Name'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
      price: price,
      categoryId: json['category_id'] ?? json['CategoryID'],
      isAvailable: isAvailable,
      stock: stock,
    );
  }
}


class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? json['ID'] ?? '',
      name: json['name'] ?? json['Name'] ?? '',
    );
  }
}
