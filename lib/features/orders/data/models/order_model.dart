class OrderModel {
  final String id;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final List<OrderItemModel> items;
  final String customerName;

  OrderModel({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
    required this.customerName,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      customerName: json['user_name'] ?? 'Unknown',
      items: (json['items'] as List?)?.map((i) => OrderItemModel.fromJson(i)).toList() ?? [],
    );
  }
}

class OrderItemModel {
  final String name;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['menu_item_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
