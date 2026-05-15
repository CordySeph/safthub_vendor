import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../../data/models/inventory_model.dart';

class InventoryHistoryScreen extends StatefulWidget {
  final InventoryItem item;
  const InventoryHistoryScreen({super.key, required this.item});

  @override
  State<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> {
  List<InventoryHistory> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await context.read<InventoryProvider>().getHistory(widget.item.menuItemId);
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory History'),
      ),
      body: Column(
        children: [
          _buildItemHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)))
                : _history.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryTile(_history[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: const Color(0xFFFF7A00).withValues(alpha: 0.2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (widget.item.variantName != null)
            Text('Variant: ${widget.item.variantName}', style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
          const SizedBox(height: 4),
          Text('Current Stock: ${widget.item.currentStock}', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.history, size: 64, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text('No history records found', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(InventoryHistory entry) {
    final isIncrease = entry.change > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isIncrease ? Colors.green : Colors.red).withValues(alpha: 0.1),
          child: Icon(
            isIncrease ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
            color: isIncrease ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${isIncrease ? "+" : ""}${entry.change}',
              style: TextStyle(fontWeight: FontWeight.bold, color: isIncrease ? Colors.green : Colors.red),
            ),
            Text(
              _formatDate(entry.createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Result: ${entry.newStock} (from ${entry.oldStock})', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('Reason: ${entry.reason.isEmpty ? "No reason provided" : entry.reason}', style: const TextStyle(fontWeight: FontWeight.w500)),
            if (entry.updatedBy != null)
              Text('By: ${entry.updatedBy}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
