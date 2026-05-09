import 'package:chefship_vendor/core/api/api_client.dart';
import 'package:chefship_vendor/features/menu/data/models/menu_item_model.dart';

class MenuService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/v2/categories/', data: data);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createMenuItem(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/vendor/menu', data: data);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMenuItem(String menuId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/vendor/menu/$menuId', data: data);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<MenuItemModel>> getMenuItems() async {
    try {
      final response = await _apiClient.dio.get('/vendor/menu');
      final List data = response.data ?? [];
      return data.map((json) => MenuItemModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/v2/categories');
      final List data = response.data ?? [];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
