import 'package:flutter/material.dart';
import '../../data/models/inventory_model.dart';
import '../../data/services/inventory_service.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();

  List<InventoryItem> _items = [];
  List<InventoryAlert> _alerts = [];
  InventorySettings? _settings;
  bool _isLoading = false;

  List<InventoryItem> get items => _items;
  List<InventoryAlert> get alerts => _alerts;
  InventorySettings? get settings => _settings;
  bool get isLoading => _isLoading;

  int get unreadAlertsCount => _alerts.where((a) => !a.isRead).length;

  Future<void> fetchInventory({bool? lowStock, bool? outOfStock, String? search}) async {
    _isLoading = true;
    notifyListeners();

    _items = await _inventoryService.getInventoryStatus(
      lowStock: lowStock,
      outOfStock: outOfStock,
      search: search,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAlerts() async {
    _alerts = await _inventoryService.getAlerts();
    notifyListeners();
  }

  Future<void> fetchSettings() async {
    _settings = await _inventoryService.getSettings();
    notifyListeners();
  }

  Future<bool> updateStock(String menuItemId, int newStock, {String? variantId, String? reason}) async {
    final success = await _inventoryService.updateSingleItemStock(menuItemId, {
      'stock': newStock,
      ...?variantId != null ? {'variant_id': variantId} : null,
      ...?reason != null ? {'reason': reason} : null,
    });

    if (success) {
      await fetchInventory();
    }
    return success;
  }

  Future<bool> batchUpdate(List<Map<String, dynamic>> updates) async {
    _isLoading = true;
    notifyListeners();

    final success = await _inventoryService.batchUpdateStock(updates);

    if (success) {
      await fetchInventory();
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> markAlertRead(String alertId) async {
    final success = await _inventoryService.markAlertAsRead(alertId);
    if (success) {
      final index = _alerts.indexWhere((a) => a.id == alertId);
      if (index != -1) {
        _alerts[index] = InventoryAlert(
          id: _alerts[index].id,
          menuItemId: _alerts[index].menuItemId,
          variantId: _alerts[index].variantId,
          itemName: _alerts[index].itemName,
          type: _alerts[index].type,
          currentStock: _alerts[index].currentStock,
          isRead: true,
          createdAt: _alerts[index].createdAt,
        );
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> markAllAlertsRead() async {
    final success = await _inventoryService.markAllAlertsAsRead();
    if (success) {
      await fetchAlerts();
    }
    return success;
  }

  Future<bool> updateInventorySettings(InventorySettings newSettings) async {
    final success = await _inventoryService.updateSettings(newSettings.toJson());
    if (success) {
      _settings = newSettings;
      notifyListeners();
    }
    return success;
  }

  Future<List<InventoryHistory>> getHistory(String menuItemId) async {
    return await _inventoryService.getHistory(menuItemId);
  }
}
