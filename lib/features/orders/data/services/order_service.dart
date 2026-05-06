import 'package:chefship_vendor/core/api/api_client.dart';
import 'package:chefship_vendor/features/orders/data/models/order_model.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  Future<List<OrderModel>> getOrders({String? status}) async {
    try {
      final response = await _apiClient.dio.get('/vendor/orders', queryParameters: {
        'status': status,
      });
      
      final List data = response.data['data'] ?? [];
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _apiClient.dio.patch('/vendor/orders/$orderId/status', data: {
        'status': status,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
