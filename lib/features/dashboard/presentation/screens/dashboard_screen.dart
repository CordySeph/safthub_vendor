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
    final dashboardProvider = context.read<DashboardProvider>();

    return RefreshIndicator(
      onRefresh: () => dashboardProvider.fetchSummary(),
      color: const Color(0xFFFF7A00),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    Text(
                      auth.restaurant?.name ?? 'Store Owner',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
                _buildPeriodDropdown(dashboardProvider),
              ],
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
                  title: 'Revenue',
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
                  value: auth.restaurant?.rating.toStringAsFixed(1) ?? '0.0',
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
            
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(),
            
            const SizedBox(height: 32),
            
            const Text(
              'Popular Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPopularItems(summary?['popular_items']),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodDropdown(DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: DropdownButton<String>(
        value: provider.currentPeriod,
        underline: const SizedBox(),
        icon: const Icon(LucideIcons.chevronDown, size: 16),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        onChanged: (String? newValue) {
          if (newValue != null) {
            provider.fetchSummary(period: newValue);
          }
        },
        items: const [
          DropdownMenuItem(value: 'today', child: Text('Today')),
          DropdownMenuItem(value: 'week', child: Text('This Week')),
          DropdownMenuItem(value: 'month', child: Text('This Month')),
          DropdownMenuItem(value: 'year', child: Text('This Year')),
          DropdownMenuItem(value: 'all_time', child: Text('All Time')),
        ],
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
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

  Widget _buildPopularItems(List<dynamic>? items) {
    if (items == null || items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No data available for this period',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: items.map((item) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(LucideIcons.utensils, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
          title: Text(item['menu_item_name'] ?? 'Unknown Item', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
          subtitle: Text('${item['total_quantity_sold'] ?? 0} sold', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
          trailing: Text('฿${item['total_revenue'] ?? 0}', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }
}
