import 'package:chefship_vendor/core/api/api_client.dart';
import '../models/addon_model.dart';

class AddonService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AddonGroup>> getAddonGroups(String restaurantId) async {
    try {
      final response = await _apiClient.dio.get('/api/vendor/restaurants/$restaurantId/addon-groups');
      final List data = response.data ?? [];
      return data.map((json) => AddonGroup.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createAddonGroup(String restaurantId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/vendor/restaurants/$restaurantId/addon-groups', data: data);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createAddonItem(String restaurantId, String groupId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/vendor/restaurants/$restaurantId/addon-groups/$groupId/items', data: data);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
