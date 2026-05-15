import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../../../../core/widgets/stat_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAnalytics(period: _selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => analytics.loadAnalytics(period: _selectedPeriod),
          ),
        ],
      ),
      body: analytics.isLoading && analytics.salesSummary == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)))
          : RefreshIndicator(
              onRefresh: () => analytics.loadAnalytics(period: _selectedPeriod),
              color: const Color(0xFFFF7A00),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Performance Overview'),
                  const SizedBox(height: 16),
                  _buildPerformanceGrid(analytics),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Financial Summary'),
                  const SizedBox(height: 16),
                  _buildFinancialCard(analytics),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Popular Items'),
                  const SizedBox(height: 16),
                  _buildPopularItemsList(analytics),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = {'today': 'Today', 'week': 'Week', 'month': 'Month', 'year': 'Year'};
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: periods.entries.map((p) {
          final isSelected = _selectedPeriod == p.key;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPeriod = p.key);
                context.read<AnalyticsProvider>().loadAnalytics(period: p.key);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF7A00) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  p.value,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPerformanceGrid(AnalyticsProvider analytics) {
    final summary = analytics.salesSummary;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          title: 'Total Revenue',
          value: '฿${summary?.totalRevenue.toStringAsFixed(0) ?? '0'}',
          icon: LucideIcons.banknote,
          iconColor: const Color(0xFFFF7A00),
        ),
        StatCard(
          title: 'Orders',
          value: '${summary?.totalOrders ?? '0'}',
          icon: LucideIcons.shoppingBag,
          iconColor: Colors.blue,
        ),
        StatCard(
          title: 'Avg. Order',
          value: '฿${summary?.averageOrderValue.toStringAsFixed(0) ?? '0'}',
          icon: LucideIcons.trendingUp,
          iconColor: Colors.green,
        ),
        StatCard(
          title: 'Trend',
          value: '+12%', // Mock trend
          icon: LucideIcons.barChart,
          iconColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildFinancialCard(AnalyticsProvider analytics) {
    final finance = analytics.financialSummary;
    if (finance == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Balance', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('฿ 45,200', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Withdraw'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 24),
          Row(
            children: [
              _financeInfo('Total Earned', '฿${finance.totalRevenue.toStringAsFixed(0)}'),
              const SizedBox(width: 32),
              _financeInfo('Paid Out', '฿${finance.totalPayouts.toStringAsFixed(0)}'),
              const SizedBox(width: 32),
              _financeInfo('Pending', '฿${finance.pendingPayouts.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _financeInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPopularItemsList(AnalyticsProvider analytics) {
    if (analytics.popularItems.isEmpty) {
      return const Center(child: Text('No sales data yet', style: TextStyle(color: Colors.grey)));
    }

    return Column(
      children: analytics.popularItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.utensils, color: Color(0xFFFF7A00), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.menuItemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${item.totalQuantitySold} sold', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Text(
                '฿${item.totalRevenue.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
