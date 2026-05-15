import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _period = 'month';
  int _currentPage = 1;
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final result = await context.read<AnalyticsProvider>().fetchTransactions(
      period: _period,
      page: _currentPage,
    );
    if (mounted) {
      setState(() {
        _transactions = result['data'] ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          _buildPeriodSelector(),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  Widget _buildPeriodSelector() {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.filter),
      onSelected: (val) {
        setState(() {
          _period = val;
          _currentPage = 1;
        });
        _loadData();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'today', child: Text('Today')),
        const PopupMenuItem(value: 'week', child: Text('This Week')),
        const PopupMenuItem(value: 'month', child: Text('This Month')),
        const PopupMenuItem(value: 'all_time', child: Text('All Time')),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.fileX, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No transactions found'),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        final DateTime date = DateTime.parse(tx['CreatedAt']);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFF0E0),
              child: Icon(LucideIcons.shoppingBag, color: Color(0xFFFF7A00), size: 20),
            ),
            title: Text('Order #${tx['ID'].toString().substring(0, 8).toUpperCase()}'),
            subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(date)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '฿${tx['TotalPrice']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  tx['Status'].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(tx['Status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
