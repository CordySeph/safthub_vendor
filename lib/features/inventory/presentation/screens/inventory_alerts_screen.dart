import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../../data/models/inventory_model.dart';

class InventoryAlertsScreen extends StatelessWidget {
  const InventoryAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Alerts'),
        actions: [
          if (inventoryProvider.alerts.isNotEmpty)
            TextButton(
              onPressed: () => inventoryProvider.markAllAlertsRead(),
              child: const Text('Mark All Read', style: TextStyle(color: Color(0xFFFF7A00))),
            ),
        ],
      ),
      body: inventoryProvider.alerts.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: inventoryProvider.alerts.length,
              itemBuilder: (context, index) {
                return _buildAlertCard(context, inventoryProvider.alerts[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bellOff, size: 64, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text('No inventory alerts', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, InventoryAlert alert) {
    final isOut = alert.type == 'out_of_stock' || alert.currentStock == 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: alert.isRead ? Theme.of(context).cardTheme.color : (isOut ? Colors.red.withValues(alpha: 0.05) : Colors.orange.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.isRead ? Colors.transparent : (isOut ? Colors.red.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          if (!alert.isRead) {
            context.read<InventoryProvider>().markAlertRead(alert.id);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: (isOut ? Colors.red : Colors.orange).withValues(alpha: 0.1),
                child: Icon(
                  isOut ? LucideIcons.alertCircle : LucideIcons.alertTriangle,
                  color: isOut ? Colors.red : Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.itemName,
                      style: TextStyle(
                        fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOut ? 'Out of Stock' : 'Low Stock Warning',
                      style: TextStyle(
                        color: isOut ? Colors.red : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Current inventory: ${alert.currentStock}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(alert.createdAt),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  if (!alert.isRead)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFFFF7A00), shape: BoxShape.circle),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.day}/${time.month}';
  }
}
