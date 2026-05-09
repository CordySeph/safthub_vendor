import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:chefship_vendor/core/widgets/stat_card.dart';
import 'package:chefship_vendor/core/widgets/shimmer_loading.dart';
import 'package:chefship_vendor/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:chefship_vendor/features/auth/presentation/providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final summary = dashboard.summary;
    
    // Check if store is currently closed
    final bool isClosed = auth.restaurant?.isTemporarilyClosed ?? false;
    final bool isOnline = !isClosed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChefShip Vendor'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? Colors.green : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: isOnline,
                  activeTrackColor: const Color(0xFFFF7A00),
                  activeThumbColor: Colors.white,
                  onChanged: (value) async {
                    final success = await context.read<DashboardProvider>().updateStoreStatus(!value, value ? null : 'Closed by vendor');
                    if (success && context.mounted) {
                      // Trigger a refresh of the auth/restaurant profile
                      await context.read<AuthProvider>().loadUser();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: dashboard.isLoading ? _buildLoadingState() : _buildContent(auth, summary),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(width: 120, height: 16),
          const SizedBox(height: 8),
          const ShimmerLoading(width: 200, height: 28),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: List.generate(4, (index) => const ShimmerLoading(width: double.infinity, height: 100)),
          ),
          const SizedBox(height: 32),
          const ShimmerLoading(width: 150, height: 24),
          const SizedBox(height: 16),
          const ShimmerLoading(width: double.infinity, height: 70),
          const SizedBox(height: 12),
          const ShimmerLoading(width: double.infinity, height: 70),
        ],
      ),
    );
  }

  Widget _buildContent(AuthProvider auth, Map<String, dynamic>? summary) {
    return RefreshIndicator(
      onRefresh: () => context.read<DashboardProvider>().fetchSummary(),
      color: const Color(0xFFFF7A00),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            Text(
              auth.restaurant?.name ?? 'Store Owner',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                StatCard(
                  title: 'Today\'s Revenue',
                  value: '฿${summary?['total_revenue'] ?? '0'}',
                  icon: LucideIcons.banknote,
                  iconColor: const Color(0xFFFF7A00),
                ),
                StatCard(
                  title: 'Total Orders',
                  value: '${summary?['total_orders'] ?? '0'}',
                  icon: LucideIcons.shoppingBag,
                  iconColor: Colors.blue,
                ),
                StatCard(
                  title: 'Avg. Rating',
                  value: '4.8', // Real app would get this from summary
                  icon: LucideIcons.star,
                  iconColor: Colors.amber,
                ),
                StatCard(
                  title: 'Active Payout',
                  value: '฿0',
                  icon: LucideIcons.clock,
                  iconColor: Colors.green,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Active Orders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQuickActions(),
            
            const SizedBox(height: 32),
            
            // Popular Items (Mock)
            const Text(
              'Popular Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPopularItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(LucideIcons.plusCircle, 'Add Menu', () {}),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(LucideIcons.percent, 'Discounts', () {}),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(LucideIcons.messageSquare, 'Reviews', () {}),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: Theme.of(context).brightness == Brightness.dark ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItems() {
    final List<Map<String, dynamic>> popularItems = [
      {'name': 'Pad Thai Kung Sod', 'sold': '124', 'revenue': '฿18,600'},
      {'name': 'Tom Yum Goong', 'sold': '98', 'revenue': '฿19,600'},
    ];

    return Column(
      children: popularItems.map((item) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(LucideIcons.utensils, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          title: Text(item['name'], style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
          subtitle: Text('${item['sold']} sold', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
          trailing: Text(item['revenue'], style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }
}
