import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../../data/models/inventory_model.dart';
import 'inventory_history_screen.dart';
import 'inventory_alerts_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  bool _filterLowStock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchInventory();
      context.read<InventoryProvider>().fetchAlerts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InventoryAlertsScreen()),
                ),
              ),
              if (inventoryProvider.unreadAlertsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${inventoryProvider.unreadAlertsCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => inventoryProvider.fetchInventory(
                lowStock: _filterLowStock ? true : null,
                search: _searchController.text.isEmpty ? null : _searchController.text,
              ),
              color: const Color(0xFFFF7A00),
              child: inventoryProvider.isLoading && inventoryProvider.items.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)))
                  : inventoryProvider.items.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: inventoryProvider.items.length,
                          itemBuilder: (context, index) {
                            final item = inventoryProvider.items[index];
                            return _buildInventoryCard(item);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (v) => context.read<InventoryProvider>().fetchInventory(
              lowStock: _filterLowStock ? true : null,
              search: v.isEmpty ? null : v,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilterChip(
                label: const Text('Low Stock Only'),
                selected: _filterLowStock,
                onSelected: (v) {
                  setState(() => _filterLowStock = v);
                  context.read<InventoryProvider>().fetchInventory(
                    lowStock: v ? true : null,
                    search: _searchController.text.isEmpty ? null : _searchController.text,
                  );
                },
                selectedColor: const Color(0xFFFF7A00).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFFFF7A00),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.packageSearch, size: 64, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text('No inventory items found', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    final isLow = item.currentStock <= item.lowStockThreshold;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: isLow ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.variantName != null)
              Text('Variant: ${item.variantName}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Stock: ${item.currentStock}',
                  style: TextStyle(
                    color: isLow ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (isLow)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: const Text('LOW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.history, size: 20),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InventoryHistoryScreen(item: item)),
              ),
              tooltip: 'View History',
            ),
            IconButton(
              icon: const Icon(LucideIcons.edit3, size: 20),
              onPressed: () => _showUpdateStockDialog(item),
              tooltip: 'Update Stock',
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(InventoryItem item) {
    final controller = TextEditingController(text: item.currentStock.toString());
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock: ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'New Stock Level'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason (Optional)', hintText: 'e.g. Restock, Correction'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(controller.text);
              if (newStock != null) {
                final provider = context.read<InventoryProvider>();
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                
                final success = await provider.updateStock(
                  item.menuItemId,
                  newStock,
                  variantId: item.variantId,
                  reason: reasonController.text.isEmpty ? null : reasonController.text,
                );
                
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text(success ? 'Stock updated' : 'Failed to update stock')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
