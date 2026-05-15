import 'package:flutter/material.dart';
import 'package:chefship_vendor/features/menu/data/models/addon_model.dart';
import 'package:chefship_vendor/features/menu/data/services/addon_service.dart';

class AddonProvider extends ChangeNotifier {
  final AddonService _addonService = AddonService();

  List<AddonGroup> _groups = [];
  bool _isLoading = false;

  List<AddonGroup> get groups => _groups;
  bool get isLoading => _isLoading;

  Future<void> fetchGroups(String restaurantId) async {
    _isLoading = true;
    notifyListeners();

    _groups = await _addonService.getAddonGroups(restaurantId);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createGroup(String restaurantId, String name, int min, int max) async {
    final success = await _addonService.createAddonGroup(restaurantId, {
      'name': name,
      'minSelection': min,
      'maxSelection': max,
    });
    if (success) await fetchGroups(restaurantId);
    return success;
  }

  Future<bool> addItem(String restaurantId, String groupId, String name, double price) async {
    final success = await _addonService.createAddonItem(restaurantId, groupId, {
      'name': name,
      'price': price,
    });
    if (success) await fetchGroups(restaurantId);
    return success;
  }
}
