class SupportTicket {
  final String id;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      priority: json['priority'] ?? 'medium',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class TicketReply {
  final String id;
  final String message;
  final bool isAdminReply;
  final DateTime createdAt;

  TicketReply({
    required this.id,
    required this.message,
    required this.isAdminReply,
    required this.createdAt,
  });

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    return TicketReply(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      isAdminReply: json['is_admin_reply'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
