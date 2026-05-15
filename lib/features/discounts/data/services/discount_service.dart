import 'package:chefship_vendor/core/api/api_client.dart';
import '../models/discount_model.dart';

class DiscountService {
  final ApiClient _apiClient = ApiClient();
  final String _basePath = '/api/vendor/discounts';

  Future<List<DiscountModel>> getDiscounts() async {
    try {
      final response = await _apiClient.dio.get(_basePath);
      final List data = response.data ?? [];
      return data.map((json) => DiscountModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createDiscount(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(_basePath, data: data);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateDiscount(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('$_basePath/$id', data: data);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDiscount(String id) async {
    try {
      final response = await _apiClient.dio.delete('$_basePath/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
