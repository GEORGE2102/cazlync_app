import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/admin_providers.dart';
import '../controllers/admin_state.dart';
import '../../core/utils/formatters.dart';

class AdvancedAnalyticsScreen extends ConsumerStatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  ConsumerState<AdvancedAnalyticsScreen> createState() =>
      _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState
    extends ConsumerState<AdvancedAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7d';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() {
      ref.read(adminControllerProvider.notifier).loadAdminData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Advanced Analytics'),
        elevation: 0,
        actions: [
          // Period selector
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7d', child: Text('Last 7 Days')),
              const PopupMenuItem(value: '30d', child: Text('Last 30 Days')),
              const PopupMenuItem(value: '90d', child: Text('Last 90 Days')),
              const PopupMenuItem(value: 'all', child: Text('All Time')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(_getPeriodLabel()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(adminControllerProvider.notifier).loadAdminData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: 'Users', icon: Icon(Icons.people, size: 20)),
            Tab(text: 'Listings', icon: Icon(Icons.directions_car, size: 20)),
            Tab(text: 'Revenue', icon: Icon(Icons.attach_money, size: 20)),
          ],
        ),
      ),
      body: adminState.status == AdminStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(adminState),
                _buildUsersTab(adminState),
                _buildListingsTab(adminState),
                _buildRevenueTab(adminState),
              ],
            ),
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case '7d':
        return '7 Days';
      case '30d':
        return '30 Days';
      case '90d':
        return '90 Days';
      case 'all':
        return 'All Time';
      default:
        return '7 Days';
    }
  }

  // Overview Tab
  Widget _buildOverviewTab(AdminState state) {
    final analytics = state.analytics ?? {};
    final userStats = state.userStats ?? {};
    final listingStats = state.listingStats ?? {};

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(adminControllerProvider.notifier).loadAdminData();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key Metrics Cards
            _buildKeyMetricsGrid(userStats, listingStats, analytics),
            const SizedBox(height: 24),

            // Growth Chart
            _buildSectionHeader('Platform Growth', Icons.trending_up),
            const SizedBox(height: 16),
            _buildGrowthChart(analytics),
            const SizedBox(height: 24),

            // Activity Heatmap
            _buildSectionHeader('Activity Overview', Icons.calendar_today),
            const SizedBox(height: 16),
            _buildActivityHeatmap(),
            const SizedBox(height: 24),

            // Quick Stats
            _buildSectionHeader('Quick Stats', Icons.speed),
            const SizedBox(height: 16),
            _buildQuickStats(analytics),
          ],
        ),
      ),
    );
  }

  // Users Tab
  Widget _buildUsersTab(AdminState state) {
    final userStats = state.userStats ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Users',
                  '${userStats['totalUsers'] ?? 0}',
                  Icons.people,
                  Colors.blue,
                  '+12%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active Today',
                  '${userStats['activeUsers'] ?? 0}',
                  Icons.person_outline,
                  Colors.green,
                  '+5%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // User Growth Chart
          _buildSectionHeader('User Growth', Icons.show_chart),
          const SizedBox(height: 16),
          _buildUserGrowthChart(),
          const SizedBox(height: 24),

          // User Distribution
          _buildSectionHeader('User Distribution', Icons.pie_chart),
          const SizedBox(height: 16),
          _buildUserDistributionChart(userStats),
          const SizedBox(height: 24),

          // Top Users
          _buildSectionHeader('Most Active Users', Icons.star),
          const SizedBox(height: 16),
          _buildTopUsersList(),
        ],
      ),
    );
  }

  // Listings Tab
  Widget _buildListingsTab(AdminState state) {
    final listingStats = state.listingStats ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Listing Stats
          _buildListingStatsGrid(listingStats),
          const SizedBox(height: 24),

          // Listings by Status
          _buildSectionHeader('Listings by Status', Icons.pie_chart_outline),
          const SizedBox(height: 16),
          _buildListingStatusChart(listingStats),
          const SizedBox(height: 24),

          // Popular Brands
          _buildSectionHeader('Popular Brands', Icons.bar_chart),
          const SizedBox(height: 16),
          _buildPopularBrandsChart(),
          const SizedBox(height: 24),

          // Price Distribution
          _buildSectionHeader('Price Distribution', Icons.attach_money),
          const SizedBox(height: 16),
          _buildPriceDistributionChart(),
        ],
      ),
    );
  }

  // Revenue Tab
  Widget _buildRevenueTab(AdminState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Cards
          _buildRevenueCards(),
          const SizedBox(height: 24),

          // Revenue Chart
          _buildSectionHeader('Revenue Trend', Icons.show_chart),
          const SizedBox(height: 16),
          _buildRevenueChart(),
          const SizedBox(height: 24),

          // Premium Listings
          _buildSectionHeader('Premium Listings', Icons.star),
          const SizedBox(height: 16),
          _buildPremiumListingsStats(),
          const SizedBox(height: 24),

          // Revenue Sources
          _buildSectionHeader('Revenue Sources', Icons.pie_chart),
          const SizedBox(height: 16),
          _buildRevenueSourcesChart(),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetricsGrid(
    Map<String, dynamic> userStats,
    Map<String, dynamic> listingStats,
    Map<String, dynamic> analytics,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Total Users',
          '${userStats['totalUsers'] ?? 0}',
          Icons.people,
          Colors.blue,
          '+${analytics['newUsersLast30Days'] ?? 0} this month',
        ),
        _buildMetricCard(
          'Active Listings',
          '${listingStats['activeListings'] ?? 0}',
          Icons.directions_car,
          Colors.green,
          '${listingStats['pendingListings'] ?? 0} pending',
        ),
        _buildMetricCard(
          'Total Views',
          '${listingStats['totalViews'] ?? 0}',
          Icons.visibility,
          Colors.orange,
          'Across all listings',
        ),
        _buildMetricCard(
          'Premium',
          '${listingStats['premiumListings'] ?? 0}',
          Icons.star,
          Colors.purple,
          'Active premium',
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              change,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart(Map<String, dynamic> analytics) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Text(days[value.toInt()]);
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 3),
                const FlSpot(1, 4),
                const FlSpot(2, 3.5),
                const FlSpot(3, 5),
                const FlSpot(4, 4),
                const FlSpot(5, 6),
                const FlSpot(6, 7),
              ],
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityHeatmap() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              return Text(
                days[index],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          )