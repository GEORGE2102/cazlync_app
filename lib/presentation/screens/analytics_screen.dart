import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/admin_providers.dart';
import '../controllers/admin_state.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminControllerProvider);
    final analytics = adminState.analytics ?? {};
    final userStats = adminState.userStats ?? {};
    final listingStats = adminState.listingStats ?? {};
    final chatStats = adminState.chatStats ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(adminControllerProvider.notifier).loadAdminData();
            },
          ),
        ],
      ),
      body: adminState.status == AdminStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    'User Statistics',
                    Icons.people,
                    Theme.of(context).colorScheme.primary,
                    [
                      _buildStatRow('Total Users', '${userStats['totalUsers'] ?? 0}'),
                      _buildStatRow('Verified Users', '${userStats['verifiedUsers'] ?? 0}'),
                      _buildStatRow('Active Users', '${userStats['activeUsers'] ?? 0}'),
                      _buildStatRow('New Users (30d)', '${analytics['newUsersLast30Days'] ?? 0}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Listing Statistics',
                    Icons.directions_car,
                    Theme.of(context).colorScheme.secondary,
                    [
                      _buildStatRow('Total Listings', '${listingStats['totalListings'] ?? 0}'),
                      _buildStatRow('Active Listings', '${listingStats['activeListings'] ?? 0}'),
                      _buildStatRow('Pending Listings', '${listingStats['pendingListings'] ?? 0}'),
                      _buildStatRow('Premium Listings', '${listingStats['premiumListings'] ?? 0}'),
                      _buildStatRow('Total Views', '${listingStats['totalViews'] ?? 0}'),
                      _buildStatRow('New Listings (30d)', '${analytics['newListingsLast30Days'] ?? 0}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Chat Statistics',
                    Icons.chat,
                    Theme.of(context).colorScheme.tertiary,
                    [
                      _buildStatRow('Total Chats', '${chatStats['totalChatSessions'] ?? 0}'),
                      _buildStatRow('Chats (30d)', '${chatStats['chatSessionsLast30Days'] ?? 0}'),
                      _buildStatRow('Total Messages', '${chatStats['totalMessages'] ?? 0}'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
