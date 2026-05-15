import 'package:flutter/material.dart';
import '../../data/models/ticket_model.dart';
import '../../data/services/support_service.dart';

class SupportProvider extends ChangeNotifier {
  final SupportService _supportService = SupportService();

  List<SupportTicket> _tickets = [];
  bool _isLoading = false;

  List<SupportTicket> get tickets => _tickets;
  bool get isLoading => _isLoading;

  Future<void> fetchTickets() async {
    _isLoading = true;
    notifyListeners();
    _tickets = await _supportService.getMyTickets();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTicket(String subject, String description, String priority) async {
    _isLoading = true;
    notifyListeners();
    final ticket = await _supportService.createTicket({
      'subject': subject,
      'description': description,
      'priority': priority,
    });
    _isLoading = false;
    if (ticket != null) {
      await fetchTickets();
      return true;
    }
    notifyListeners();
    return false;
  }
}
