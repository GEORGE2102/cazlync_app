import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/services/admin_service.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  Future<void> _verifyUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify User'),
        content: Text('Verify $userName as a trusted seller?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _adminService.verifyUser(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User verified successfully')),
        );
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _unverifyUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Verification'),
        content: Text('Remove verification from $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _adminService.unverifyUser(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification removed')),
        );
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _suspendUser(String userId, String userName) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Suspend $userName?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      try {
        await _adminService.suspendUser(userId, reasonController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User suspended')),
        );
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      final name = (user['displayName'] ?? '').toLowerCase();
      final email = (user['email'] ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatChip(
                  'Total',
                  _users.length.toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  'Verified',
                  _users.where((u) => u['isVerified'] == true).length.toString(),
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  'Suspended',
                  _users.where((u) => u['isSuspended'] == true).length.toString(),
                  Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserCard(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isVerified = user['isVerified'] == true;
    final isSuspended = user['isSuspended'] == true;
    final isAdmin = user['isAdmin'] == true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user['photoUrl'] != null
              ? NetworkImage(user['photoUrl'])
              : null,
          child: user['photoUrl'] == null
              ? Text(user['displayName']?[0] ?? 'U')
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user['displayName'] ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isVerified)
              const Icon(Icons.verified, color: Colors.blue, size: 20),
            if (isAdmin)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.admin_panel_settings, color: Colors.orange, size: 20),
              ),
            if (isSuspended)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.block, color: Colors.red, size: 20),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? ''),
            if (user['phoneNumber'] != null)
              Text(user['phoneNumber']),
            Text(
              'Joined: ${_formatDate(user['createdAt'])}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!isVerified && !isAdmin)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Verify User'),
                  ],
                ),
                onTap: () => Future.delayed(
                  Duration.zero,
                  () => _verifyUser(user['id'], user['displayName'] ?? 'User'),
                ),
              ),
            if (isVerified && !isAdmin)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.remove_circle, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Remove Verification'),
                  ],
                ),
                onTap: () => Future.delayed(
                  Duration.zero,
                  () => _unverifyUser(user['id'], user['displayName'] ?? 'User'),
                ),
              ),
            if (!isSuspended && !isAdmin)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.block, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Suspend User'),
                  ],
                ),
                onTap: () => Future.delayed(
                  Duration.zero,
                  () => _suspendUser(user['id'], user['displayName'] ?? 'User'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final date = timestamp.toDate();
      return DateFormat('MMM d, y').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }
}
