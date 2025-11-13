import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_providers.dart';

class DebugUserScreen extends ConsumerWidget {
  const DebugUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug User Data'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auth State User
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auth State User (from app)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (user != null) ...[
                      Text('ID: ${user.id}'),
                      Text('Email: ${user.email}'),
                      Text('Name: ${user.displayName}'),
                      Text('Is Admin: ${user.isAdmin}', 
                        style: TextStyle(
                          color: user.isAdmin ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else
                      const Text('No user logged in'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Firebase Auth User
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase Auth User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final firebaseUser = FirebaseAuth.instance.currentUser;
                        if (firebaseUser != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('UID: ${firebaseUser.uid}'),
                              Text('Email: ${firebaseUser.email}'),
                              Text('Display Name: ${firebaseUser.displayName}'),
                            ],
                          );
                        }
                        return const Text('No Firebase user');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Firestore Document
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firestore Document (raw)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseAuth.instance.currentUser != null
                          ? FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .snapshots()
                          : null,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        
                        if (!snapshot.data!.exists) {
                          return const Text('Document does not exist!');
                        }
                        
                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('email: ${data['email']}'),
                            Text('displayName: ${data['displayName']}'),
                            Text('isAdmin: ${data['isAdmin']}',
                              style: TextStyle(
                                color: data['isAdmin'] == true ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text('isVerified: ${data['isVerified']}'),
                            Text('createdAt: ${data['createdAt']}'),
                            const Divider(),
                            const Text('Full Document:'),
                            Text(data.toString(), style: const TextStyle(fontSize: 11)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Refresh button
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).refreshUser();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User data refreshed')),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh User Data'),
            ),
          ],
        ),
      ),
    );
  }
}
