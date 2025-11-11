import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/listing_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Get user profile
  Future<UserModel> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      throw Exception('User not found');
    }

    return UserModel.fromFirestore(doc);
  }

  // Update user profile
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};

    if (displayName != null) updates['displayName'] = displayName;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(userId).update(updates);
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto({
    required String userId,
    required String imagePath,
  }) async {
    final file = File(imagePath);
    final fileName = 'profile_$userId.jpg';
    final ref = _storage.ref().child('profile_photos/$fileName');

    // Upload file
    await ref.putFile(file);

    // Get download URL
    final downloadUrl = await ref.getDownloadURL();

    // Update user profile with new photo URL
    await updateProfile(userId: userId, photoUrl: downloadUrl);

    return downloadUrl;
  }

  // Get user's listings
  Future<List<ListingModel>> getUserListings(String userId) async {
    final snapshot = await _firestore
        .collection('listings')
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ListingModel.fromFirestore(doc))
        .toList();
  }

  // Delete user listing
  Future<void> deleteUserListing(String listingId) async {
    await _firestore.collection('listings').doc(listingId).update({
      'status': 'deleted',
    });
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats(String userId) async {
    // Get total listings count
    final listingsSnapshot = await _firestore
        .collection('listings')
        .where('sellerId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    // Get favorites count
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data()!;
    final favoritesCount =
        (userData['favoriteListings'] as List?)?.length ?? 0;

    // Get total views across all listings
    int totalViews = 0;
    for (final doc in listingsSnapshot.docs) {
      final data = doc.data();
      totalViews += (data['viewCount'] as int?) ?? 0;
    }

    // Get chat sessions count (as buyer or seller)
    final buyerChatsSnapshot = await _firestore
        .collection('chatSessions')
        .where('buyerId', isEqualTo: userId)
        .get();

    final sellerChatsSnapshot = await _firestore
        .collection('chatSessions')
        .where('sellerId', isEqualTo: userId)
        .get();

    final chatsCount =
        buyerChatsSnapshot.docs.length + sellerChatsSnapshot.docs.length;

    return {
      'listings': listingsSnapshot.docs.length,
      'favorites': favoritesCount,
      'views': totalViews,
      'chats': chatsCount,
    };
  }
}
