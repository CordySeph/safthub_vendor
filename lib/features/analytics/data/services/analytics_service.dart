import 'package:chefship_vendor/core/api/api_client.dart';
import '../models/analytics_model.dart';

class AnalyticsService {
  final ApiClient _apiClient = ApiClient();
  final String _basePath = '/api/vendor/analytics';

  Future<SalesSummary?> getSalesSummary({String period = 'all_time'}) async {
    try {
      final response = await _apiClient.dio.get('$_basePath/summary', queryParameters: {'period': period});
      return SalesSummary.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<FinancialSummary?> getFinancialSummary() async {
    try {
      final response = await _apiClient.dio.get('$_basePath/financial-summary');
      return FinancialSummary.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<RevenueDataPoint>> getRevenueOverTime({String period = 'day', String filterPeriod = 'month'}) async {
    try {
      final response = await _apiClient.dio.get('$_basePath/revenue-over-time', queryParameters: {
        'period': period,
        'filter_period': filterPeriod,
      });
      final List data = response.data ?? [];
      return data.map((json) => RevenueDataPoint.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PopularItem>> getPopularItems({int limit = 5}) async {
    try {
      final response = await _apiClient.dio.get('$_basePath/popular-items', queryParameters: {'limit': limit});
      final List data = response.data ?? [];
      return data.map((json) => PopularItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getTransactions({String period = 'month', int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.dio.get('$_basePath/transactions', queryParameters: {
        'period': period,
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      return {'data': [], 'pagination': {'currentPage': 1, 'totalPages': 0, 'totalItems': 0}};
    }
  }

  Future<Map<String, dynamic>> getPayoutHistory({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.dio.get('$_basePath/payout-history', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      return {'data': [], 'pagination': {'currentPage': 1, 'totalPages': 0, 'totalItems': 0}};
    }
  }
}
