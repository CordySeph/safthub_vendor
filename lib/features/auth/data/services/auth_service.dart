import 'package:dio/dio.dart';
import 'package:chefship_vendor/core/api/api_client.dart';
import 'package:chefship_vendor/features/auth/data/models/user_model.dart';
import 'package:chefship_vendor/features/auth/data/models/restaurant_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<String?> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        return response.data['token'];
      }
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Login failed';
    }
    return null;
  }

  Future<UserModel?> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<RestaurantModel?> getMyRestaurant() async {
    try {
      final response = await _apiClient.dio.get('/vendor/my-restaurant');
      if (response.statusCode == 200) {
        return RestaurantModel.fromJson(response.data);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> logout() async {
    // Add server-side logout if necessary, for now we just clear the token locally in provider
  }
}
