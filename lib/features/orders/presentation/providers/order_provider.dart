import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _newOrders = [];
  List<OrderModel> _activeOrders = [];
  List<OrderModel> _orderHistory = [];
  bool _isLoading = false;

  List<OrderModel> get newOrders => _newOrders;
  List<OrderModel> get activeOrders => _activeOrders;
  List<OrderModel> get orderHistory => _orderHistory;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    _newOrders = await _orderService.getOrders(status: 'pending');
    _activeOrders = await _orderService.getOrders(status: 'accepted'); // Includes preparing/ready in real app
    _orderHistory = await _orderService.getOrders(status: 'delivered');

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateStatus(String orderId, String status) async {
    final success = await _orderService.updateOrderStatus(orderId, status);
    if (success) {
      await fetchOrders();
    }
    return success;
  }
}
