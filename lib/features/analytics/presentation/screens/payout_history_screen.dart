import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import 'package:intl/intl.dart';

class PayoutHistoryScreen extends StatefulWidget {
  const PayoutHistoryScreen({super.key});

  @override
  State<PayoutHistoryScreen> createState() => _PayoutHistoryScreenState();
}

class _PayoutHistoryScreenState extends State<PayoutHistoryScreen> {
  final int _currentPage = 1;
  List<dynamic> _payouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await context.read<AnalyticsProvider>().fetchPayoutHistory(
      page: _currentPage,
    );
    if (mounted) {
      setState(() {
        _payouts = result['data'] ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout History'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _payouts.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No payout history found'),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payouts.length,
      itemBuilder: (context, index) {
        final po = _payouts[index];
        final DateTime requestedDate = DateTime.parse(po['RequestedAt']);
        final DateTime? processedDate = po['ProcessedAt'] != null ? DateTime.parse(po['ProcessedAt']) : null;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(LucideIcons.landmark, color: Colors.green, size: 20),
            ),
            title: Text('Payout ฿${po['Amount']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Requested: ${DateFormat('dd MMM yyyy').format(requestedDate)}'),
                if (processedDate != null)
                  Text('Processed: ${DateFormat('dd MMM yyyy').format(processedDate)}'),
              ],
            ),
            trailing: _buildStatusChip(po['Status']),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
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
}
