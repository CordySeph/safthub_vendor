import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/discount_provider.dart';
import '../../data/models/discount_model.dart';
import 'add_edit_discount_screen.dart';

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({super.key});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscountProvider>().fetchDiscounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final discountProvider = context.watch<DiscountProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Discounts'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => discountProvider.fetchDiscounts(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => discountProvider.fetchDiscounts(),
        color: const Color(0xFFFF7A00),
        child: discountProvider.isLoading && discountProvider.discounts.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)))
            : discountProvider.discounts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: discountProvider.discounts.length,
                    itemBuilder: (context, index) {
                      final discount = discountProvider.discounts[index];
                      return _buildDiscountCard(discount);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditDiscountScreen()),
        ),
        backgroundColor: const Color(0xFFFF7A00),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.ticket, size: 64, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text('No discounts created yet', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditDiscountScreen()),
            ),
            child: const Text('Create First Discount'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountCard(DiscountModel discount) {
    final isExpired = discount.endDate.isBefore(DateTime.now());
    final statusColor = discount.isActive && !isExpired ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Text(
                  discount.code,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFFF7A00)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isExpired ? 'EXPIRED' : (discount.isActive ? 'ACTIVE' : 'INACTIVE'),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  discount.type == 'percentage' 
                      ? '${discount.value.toInt()}% Off' 
                      : '฿${discount.value.toInt()} Off',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Min. order: ฿${discount.minOrderValue.toInt()}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Valid: ${_formatDate(discount.startDate)} - ${_formatDate(discount.endDate)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddEditDiscountScreen(discount: discount)),
                  );
                } else if (val == 'delete') {
                  _showDeleteDialog(discount);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2C2C2C)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Status', style: TextStyle(fontSize: 13)),
                Switch(
                  value: discount.isActive,
                  activeTrackColor: const Color(0xFFFF7A00),
                  activeThumbColor: Colors.white,
                  onChanged: (v) => context.read<DiscountProvider>().toggleDiscountStatus(discount.id, v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(DiscountModel discount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Discount'),
        content: Text('Are you sure you want to delete "${discount.code}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<DiscountProvider>().deleteDiscount(discount.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
