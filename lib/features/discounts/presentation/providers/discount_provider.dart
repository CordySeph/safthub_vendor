import 'package:flutter/material.dart';
import '../../data/models/discount_model.dart';
import '../../data/services/discount_service.dart';

class DiscountProvider extends ChangeNotifier {
  final DiscountService _discountService = DiscountService();

  List<DiscountModel> _discounts = [];
  bool _isLoading = false;

  List<DiscountModel> get discounts => _discounts;
  bool get isLoading => _isLoading;

  Future<void> fetchDiscounts() async {
    _isLoading = true;
    notifyListeners();

    _discounts = await _discountService.getDiscounts();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createDiscount(DiscountModel discount) async {
    _isLoading = true;
    notifyListeners();

    final success = await _discountService.createDiscount(discount.toJson());
    if (success) {
      await fetchDiscounts();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateDiscount(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final success = await _discountService.updateDiscount(id, data);
    if (success) {
      await fetchDiscounts();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteDiscount(String id) async {
    _isLoading = true;
    notifyListeners();

    final success = await _discountService.deleteDiscount(id);
    if (success) {
      await fetchDiscounts();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> toggleDiscountStatus(String id, bool isActive) async {
    return await updateDiscount(id, {'isActive': isActive});
  }
}
