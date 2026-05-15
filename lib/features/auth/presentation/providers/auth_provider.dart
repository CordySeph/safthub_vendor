import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chefship_vendor/core/constants/app_constants.dart';
import 'package:chefship_vendor/features/auth/data/models/user_model.dart';
import 'package:chefship_vendor/features/auth/data/models/restaurant_model.dart';
import 'package:chefship_vendor/features/auth/data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserModel? _user;
  RestaurantModel? _restaurant;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  RestaurantModel? get restaurant => _restaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null) {
      _user = await _authService.getProfile();
      if (_user != null && _user!.role.toLowerCase() == 'vendor') {
        _restaurant = await _authService.getMyRestaurant();
      }
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authService.login(email, password);
      if (token != null) {
        await _storage.write(key: AppConstants.tokenKey, value: token);
        _user = await _authService.getProfile();
        if (_user != null && _user!.role.toLowerCase() == 'vendor') {
          _restaurant = await _authService.getMyRestaurant();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password, String? phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.register({
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'role': 'vendor',
      });
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<Map<String, dynamic>?> checkStoreLocation(double lat, double lng) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.checkLocation(lat, lng);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> registerStore(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.registerStore(data);
      if (success) {
        _restaurant = await _authService.getMyRestaurant();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    _user = null;
    _restaurant = null;
    notifyListeners();
  }
}
