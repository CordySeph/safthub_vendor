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
    // Extract price from the first variant if available
    double price = 0.0;
    bool isAvailable = true;
    int stock = 0;

    final variants = json['Variants'] as List?;
    if (variants != null && variants.isNotEmpty) {
      final firstVariant = variants.first;
      price = (firstVariant['Price'] ?? 0).toDouble();
      isAvailable = firstVariant['IsAvailable'] ?? true;
      stock = firstVariant['Stock'] ?? 0;
    }

    return MenuItemModel(
      id: json['ID'] ?? '',
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',
      price: price,
      categoryId: json['CategoryID'],
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
