import 'package:flutter/material.dart';
import 'package:chefship_vendor/core/api/api_client.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  Map<String, dynamic>? _summary;
  bool _isLoading = false;

  Map<String, dynamic>? get summary => _summary;
  bool get isLoading => _isLoading;

  Future<void> fetchSummary() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/vendor/analytics/summary', queryParameters: {
        'period': 'today',
      });
      _summary = response.data;
    } catch (e) {
      _summary = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}
