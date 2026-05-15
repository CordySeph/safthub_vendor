import 'package:chefship_vendor/core/api/api_client.dart';
import '../models/ticket_model.dart';

class SupportService {
  final ApiClient _apiClient = ApiClient();
  final String _basePath = '/api/support/tickets';

  Future<List<SupportTicket>> getMyTickets() async {
    try {
      final response = await _apiClient.dio.get(_basePath);
      final List data = response.data['data'] ?? response.data ?? [];
      return data.map((json) => SupportTicket.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<SupportTicket?> createTicket(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(_basePath, data: data);
      return SupportTicket.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTicketDetails(String ticketId) async {
    try {
      final response = await _apiClient.dio.get('$_basePath/$ticketId');
      final ticket = SupportTicket.fromJson(response.data['ticket']);
      final replies = (response.data['replies'] as List)
          .map((json) => TicketReply.fromJson(json))
          .toList();
      return {'ticket': ticket, 'replies': replies};
    } catch (e) {
      return null;
    }
  }

  Future<TicketReply?> addReply(String ticketId, String message) async {
    try {
      final response = await _apiClient.dio.post('$_basePath/$ticketId/replies', data: {
        'message': message,
      });
      return TicketReply.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
