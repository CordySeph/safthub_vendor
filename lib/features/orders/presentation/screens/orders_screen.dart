import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:chefship_vendor/features/orders/presentation/providers/order_provider.dart';
import 'package:chefship_vendor/features/orders/data/models/order_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Management'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF7A00),
          labelColor: const Color(0xFFFF7A00),
          unselectedLabelColor: const Color(0xFF666666),
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => orderProvider.fetchOrders(),
          ),
        ],
      ),
      body: orderProvider.isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orderProvider.newOrders, 'New'),
              _buildOrderList(orderProvider.activeOrders, 'Active'),
              _buildOrderList(orderProvider.orderHistory, 'History'),
            ],
          ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, String type) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.clipboardList, size: 64, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(
              'No $type orders yet',
              style: const TextStyle(color: Color(0xFF666666), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, type);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: type == 'New' 
          ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5), width: 1)
          : null,
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id.substring(0, 8).toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              Text(
                _formatTime(order.createdAt),
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6), fontSize: 12),
              ),
            ],
          ),
          const Divider(color: Color(0xFF2C2C2C), height: 24),
          Text(
            order.customerName,
            style: TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          ... order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text('• ${item.name} x${item.quantity}', 
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
          )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ฿${order.totalPrice}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary),
              ),
              _buildActionButtons(order),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  Widget _buildActionButtons(OrderModel order) {
    if (order.status == 'pending') {
      return Row(
        children: [
          _smallButton('Reject', Colors.red, () {
            context.read<OrderProvider>().updateStatus(order.id, 'rejected');
          }),
          const SizedBox(width: 8),
          _smallButton('Accept', Colors.green, () {
            context.read<OrderProvider>().updateStatus(order.id, 'accepted');
          }),
        ],
      );
    } else if (order.status == 'accepted') {
      return _smallButton('Mark as Ready', const Color(0xFFFF7A00), () {
        context.read<OrderProvider>().updateStatus(order.id, 'ready_for_pickup');
      });
    }
    
    return Text(
      order.status.toUpperCase(),
      style: TextStyle(
        color: order.status == 'delivered' ? Colors.green : Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  Widget _smallButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        minimumSize: const Size(80, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        elevation: 0,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
