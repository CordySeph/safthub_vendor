import 'package:flutter/material.dart';
import '../../data/models/analytics_model.dart';
import '../../data/services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  SalesSummary? _salesSummary;
  FinancialSummary? _financialSummary;
  List<RevenueDataPoint> _revenueTrend = [];
  List<PopularItem> _popularItems = [];
  bool _isLoading = false;

  SalesSummary? get salesSummary => _salesSummary;
  FinancialSummary? get financialSummary => _financialSummary;
  List<RevenueDataPoint> get revenueTrend => _revenueTrend;
  List<PopularItem> get popularItems => _popularItems;
  bool get isLoading => _isLoading;

  Future<void> loadAnalytics({String period = 'month'}) async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait([
      _analyticsService.getSalesSummary(period: period),
      _analyticsService.getFinancialSummary(),
      _analyticsService.getRevenueOverTime(period: 'day', filterPeriod: period),
      _analyticsService.getPopularItems(),
    ]);

    _salesSummary = results[0] as SalesSummary?;
    _financialSummary = results[1] as FinancialSummary?;
    _revenueTrend = results[2] as List<RevenueDataPoint>;
    _popularItems = results[3] as List<PopularItem>;

    _isLoading = false;
    notifyListeners();
  }
}
