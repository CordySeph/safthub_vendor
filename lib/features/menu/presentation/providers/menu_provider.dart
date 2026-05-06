import 'package:flutter/material.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/services/menu_service.dart';

class MenuProvider extends ChangeNotifier {
  final MenuService _menuService = MenuService();

  List<MenuItemModel> _menuItems = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<MenuItemModel> get menuItems => _menuItems;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _menuItems = await _menuService.getMenuItems();
    _categories = await _menuService.getCategories();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createMenuItem(String name, String description, double price, String categoryId, int stock) async {
    _isLoading = true;
    notifyListeners();

    final success = await _menuService.createMenuItem({
      'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId,
      'stock_quantity': stock,
      'is_active': true,
    });

    if (success) {
      await loadData();
    }
    _isLoading = false;
    notifyListeners();
    return success;
  }

}
