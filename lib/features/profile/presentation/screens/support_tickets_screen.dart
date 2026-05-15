import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/support_provider.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().fetchTickets();
    });
  }

  void _showCreateTicketDialog() {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Support Ticket'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  items: ['low', 'medium', 'high']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase())))
                      .toList(),
                  onChanged: (val) => setState(() => priority = val!),
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await context.read<SupportProvider>().createTicket(
                  subjectController.text,
                  descriptionController.text,
                  priority,
                );
                if (!context.mounted) return;
                if (success) Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final supportProvider = context.watch<SupportProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Tickets'),
      ),
      body: supportProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : supportProvider.tickets.isEmpty
              ? _buildEmptyState()
              : _buildTicketList(supportProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTicketDialog,
        backgroundColor: const Color(0xFFFF7A00),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.helpCircle, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No support tickets yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList(SupportProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.tickets.length,
      itemBuilder: (context, index) {
        final ticket = provider.tickets[index];
        return Card(
          child: ListTile(
            title: Text(ticket.subject),
            subtitle: Text(
              ticket.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusChip(ticket.status),
                const SizedBox(height: 4),
                Text(
                  ticket.priority.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getPriorityColor(ticket.priority),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Navigate to details
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'open':
        color = Colors.blue;
        break;
      case 'resolved':
        color = Colors.green;
        break;
      case 'closed':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
