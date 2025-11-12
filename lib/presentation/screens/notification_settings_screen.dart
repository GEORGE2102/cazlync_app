import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  Map<String, bool> _settings = {
    'messages': true,
    'listings': true,
    'favorites': true,
    'premium': true,
    'marketing': false,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        final notificationSettings =
            data?['notificationSettings'] as Map<String, dynamic>?;

        if (notificationSettings != null) {
          setState(() {
            _settings = {
              'messages': notificationSettings['messages'] ?? true,
              'listings': notificationSettings['listings'] ?? true,
              'favorites': notificationSettings['favorites'] ?? true,
              'premium': notificationSettings['premium'] ?? true,
              'marketing': notificationSettings['marketing'] ?? false,
            };
          });
        }
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      setState(() {
        _settings[key] = value;
      });

      await _firestore.collection('users').doc(userId).update({
        'notificationSettings.$key': value,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification settings updated'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating notification setting: $e');
      // Revert on error
      setState(() {
        _settings[key] = !value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update settings'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Text(
                  'Manage Notifications',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose what notifications you want to receive',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 24),

                // Messages Section
                _buildSectionHeader(
                  icon: Icons.chat_bubble,
                  title: 'Messages',
                  color: Theme.of(context).colorScheme.primary,
                ),
                _buildSettingTile(
                  title: 'New Messages',
                  subtitle: 'Get notified when you receive a new message',
                  value: _settings['messages']!,
                  onChanged: (value) => _updateSetting('messages', value),
                ),
                const Divider(height: 32),

                // Listings Section
                _buildSectionHeader(
                  icon: Icons.directions_car,
                  title: 'Listings',
                  color: Theme.of(context).colorScheme.secondary,
                ),
                _buildSettingTile(
                  title: 'Listing Status Updates',
                  subtitle:
                      'Notifications about approval, rejection, or removal',
                  value: _settings['listings']!,
                  onChanged: (value) => _updateSetting('listings', value),
                ),
                const Divider(height: 32),

                // Favorites Section
                _buildSectionHeader(
                  icon: Icons.favorite,
                  title: 'Favorites',
                  color: Theme.of(context).colorScheme.primary,
                ),
                _buildSettingTile(
                  title: 'New Favorites',
                  subtitle: 'Get notified when someone saves your listing',
                  value: _settings['favorites']!,
                  onChanged: (value) => _updateSetting('favorites', value),
                ),
                const Divider(height: 32),

                // Premium Section
                _buildSectionHeader(
                  icon: Icons.star,
                  title: 'Premium',
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                _buildSettingTile(
                  title: 'Premium Expiry Reminders',
                  subtitle: 'Get notified 3 days before premium expires',
                  value: _settings['premium']!,
                  onChanged: (value) => _updateSetting('premium', value),
                ),
                const Divider(height: 32),

                // Marketing Section
                _buildSectionHeader(
                  icon: Icons.campaign,
                  title: 'Marketing',
                  color: Colors.blue,
                ),
                _buildSettingTile(
                  title: 'Promotional Offers',
                  subtitle: 'Receive updates about new features and offers',
                  value: _settings['marketing']!,
                  onChanged: (value) => _updateSetting('marketing', value),
                ),
                const SizedBox(height: 32),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You can change these settings anytime. Some notifications may still be sent for important account updates.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}
