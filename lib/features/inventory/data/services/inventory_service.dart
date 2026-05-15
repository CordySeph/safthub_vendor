import 'package:chefship_vendor/core/api/api_client.dart';
import '../models/inventory_model.dart';

class InventoryService {
  final ApiClient _apiClient = ApiClient();
  final String _basePath = '/api/vendor/inventory';

  Future<List<InventoryItem>> getInventoryStatus({
    bool? lowStock,
    bool? outOfStock,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.dio.get(_basePath, queryParameters: {
        ...?lowStock != null ? {'low_stock': lowStock} : null,
        ...?outOfStock != null ? {'out_of_stock': outOfStock} : null,
        ...?search != null ? {'search': search} : null,
        'page': page,
        'limit': limit,
      });
      final List data = response.data['data'] ?? response.data ?? [];
      return data.map((json) => InventoryItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> batchUpdateStock(List<Map<String, dynamic>> updates) async {
    try {
      final response = await _apiClient.dio.patch('$_basePath/batch-update', data: {
        'updates': updates,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSingleItemStock(String menuItemId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('$_basePath/$menuItemId/stock', data: data);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<InventoryHistory>> getHistory(String menuItemId) async {
    try {
      final response = await _apiClient.dio.get('$_basePath/history/$menuItemId');
      final List data = response.data ?? [];
      return data.map((json) => InventoryHistory.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<InventoryAlert>> getAlerts() async {
    try {
      final response = await _apiClient.dio.get('$_basePath/alerts');
      final List data = response.data ?? [];
      return data.map((json) => InventoryAlert.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> markAlertAsRead(String alertId) async {
    try {
      final response = await _apiClient.dio.patch('$_basePath/alerts/$alertId/read');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAlertsAsRead() async {
    try {
      final response = await _apiClient.dio.patch('$_basePath/alerts/read-all');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<InventorySettings?> getSettings() async {
    try {
      final response = await _apiClient.dio.get('$_basePath/alerts/settings');
      return InventorySettings.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateSettings(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('$_basePath/alerts/settings', data: data);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
