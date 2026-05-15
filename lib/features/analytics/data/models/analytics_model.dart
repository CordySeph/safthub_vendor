class SalesSummary {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;

  SalesSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalOrders: json['total_orders'] ?? 0,
      averageOrderValue: (json['average_order_value'] ?? 0).toDouble(),
    );
  }
}

class FinancialSummary {
  final double totalRevenue;
  final double totalPayouts;
  final double balance;
  final double pendingPayouts;

  FinancialSummary({
    required this.totalRevenue,
    required this.totalPayouts,
    required this.balance,
    required this.pendingPayouts,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalPayouts: (json['total_payouts'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      pendingPayouts: (json['pending_payouts'] ?? 0).toDouble(),
    );
  }
}

class RevenueDataPoint {
  final DateTime date;
  final double revenue;

  RevenueDataPoint({required this.date, required this.revenue});

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      date: DateTime.parse(json['date']),
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class PopularItem {
  final String menuItemName;
  final int totalQuantitySold;
  final double totalRevenue;

  PopularItem({
    required this.menuItemName,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });

  factory PopularItem.fromJson(Map<String, dynamic> json) {
    return PopularItem(
      menuItemName: json['menu_item_name'] ?? '',
      totalQuantitySold: json['total_quantity_sold'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }
}
