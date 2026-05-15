class DiscountModel {
  final String id;
  final String code;
  final String type; // 'percentage' or 'fixed_amount'
  final double value;
  final double minOrderValue;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  DiscountModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrderValue,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'] ?? json['ID'] ?? '',
      code: json['code'] ?? json['Code'] ?? '',
      type: json['type'] ?? json['Type'] ?? 'percentage',
      value: (json['value'] ?? json['Value'] ?? 0).toDouble(),
      minOrderValue: (json['min_order_value'] ?? json['MinOrderValue'] ?? json['minOrderValue'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['start_date'] ?? json['StartDate'] ?? json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] ?? json['EndDate'] ?? json['endDate'] ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] ?? json['IsActive'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'value': value,
      'minOrderValue': minOrderValue,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'isActive': isActive,
    };
  }
}
