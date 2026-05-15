class InventoryItem {
  final String menuItemId;
  final String? variantId;
  final String name;
  final String? variantName;
  final int currentStock;
  final int lowStockThreshold;
  final bool isLowStock;

  InventoryItem({
    required this.menuItemId,
    this.variantId,
    required this.name,
    this.variantName,
    required this.currentStock,
    this.lowStockThreshold = 0,
    this.isLowStock = false,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      menuItemId: json['menu_item_id'] ?? '',
      variantId: json['variant_id'],
      name: json['name'] ?? '',
      variantName: json['variant_name'],
      currentStock: json['current_stock'] ?? json['stock'] ?? 0,
      lowStockThreshold: json['low_stock_threshold'] ?? 0,
      isLowStock: json['is_low_stock'] ?? false,
    );
  }
}

class InventoryHistory {
  final String id;
  final int oldStock;
  final int newStock;
  final int change;
  final String reason;
  final DateTime createdAt;
  final String? updatedBy;

  InventoryHistory({
    required this.id,
    required this.oldStock,
    required this.newStock,
    required this.change,
    required this.reason,
    required this.createdAt,
    this.updatedBy,
  });

  factory InventoryHistory.fromJson(Map<String, dynamic> json) {
    return InventoryHistory(
      id: json['id'] ?? '',
      oldStock: json['old_stock'] ?? 0,
      newStock: json['new_stock'] ?? 0,
      change: json['change'] ?? 0,
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedBy: json['updated_by'],
    );
  }
}

class InventoryAlert {
  final String id;
  final String menuItemId;
  final String? variantId;
  final String itemName;
  final String type; // 'low_stock' or 'out_of_stock'
  final int currentStock;
  final bool isRead;
  final DateTime createdAt;

  InventoryAlert({
    required this.id,
    required this.menuItemId,
    this.variantId,
    required this.itemName,
    required this.type,
    required this.currentStock,
    required this.isRead,
    required this.createdAt,
  });

  factory InventoryAlert.fromJson(Map<String, dynamic> json) {
    return InventoryAlert(
      id: json['id'] ?? '',
      menuItemId: json['menu_item_id'] ?? '',
      variantId: json['variant_id'],
      itemName: json['item_name'] ?? '',
      type: json['type'] ?? 'low_stock',
      currentStock: json['current_stock'] ?? 0,
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class InventorySettings {
  final int lowStockThreshold;
  final int outOfStockThreshold;
  final List<String> notificationMethods;
  final bool isEnabled;

  InventorySettings({
    required this.lowStockThreshold,
    required this.outOfStockThreshold,
    required this.notificationMethods,
    required this.isEnabled,
  });

  factory InventorySettings.fromJson(Map<String, dynamic> json) {
    return InventorySettings(
      lowStockThreshold: json['low_stock_threshold'] ?? 10,
      outOfStockThreshold: json['out_of_stock_threshold'] ?? 0,
      notificationMethods: List<String>.from(json['notification_methods'] ?? []),
      isEnabled: json['is_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'low_stock_threshold': lowStockThreshold,
      'out_of_stock_threshold': outOfStockThreshold,
      'notification_methods': notificationMethods,
      'is_enabled': isEnabled,
    };
  }
}
