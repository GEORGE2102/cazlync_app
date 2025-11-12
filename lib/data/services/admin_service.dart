import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class AdminService {
  final FirebaseFirestore _firestore;

  AdminService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Listing Moderation
  Future<void> approveListing(String listingId) async {
    await _firestore.collection('listings').doc(listingId).update({
      'status': 'active',
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectListing(String listingId, String reason) async {
    await _firestore.collection('listings').doc(listingId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'rejectedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeListing(String listingId) async {
    await _firestore.collection('listings').doc(listingId).update({
      'status': 'deleted',
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<ListingModel>> getPendingListings() async {
    final snapshot = await _firestore
        .collection('listings')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => ListingModel.fromFirestore(doc))
        .toList();
  }

  Future<List<ListingModel>> getReportedListings() async {
    final snapshot = await _firestore
        .collection('reports')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    final listingIds = snapshot.docs
        .map((doc) => doc.data()['listingId'] as String)
        .toSet()
        .toList();

    if (listingIds.isEmpty) return [];

    final listings = <ListingModel>[];
    for (final id in listingIds) {
      final doc = await _firestore.collection('listings').doc(id).get();
      if (doc.exists) {
        listings.add(ListingModel.fromFirestore(doc));
      }
    }

    return listings;
  }

  // Analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Get total counts
    final usersCount = await _firestore.collection('users').count().get();
    final listingsCount = await _firestore.collection('listings').count().get();
    final activeListingsCount = await _firestore
        .collection('listings')
        .where('status', isEqualTo: 'active')
        .count()
        .get();

    // Get new users in last 30 days
    final newUsersSnapshot = await _firestore
        .collection('users')
        .where('createdAt', isGreaterThan: thirtyDaysAgo)
        .count()
        .get();

    // Get new listings in last 30 days
    final newListingsSnapshot = await _firestore
        .collection('listings')
        .where('createdAt', isGreaterThan: thirtyDaysAgo)
        .count()
        .get();

    // Get chat sessions in last 30 days
    final chatSessionsSnapshot = await _firestore
        .collection('chatSessions')
        .where('createdAt', isGreaterThan: thirtyDaysAgo)
        .count()
        .get();

    return {
      'totalUsers': usersCount.count,
      'totalListings': listingsCount.count,
      'activeListings': activeListingsCount.count,
      'newUsersLast30Days': newUsersSnapshot.count,
      'newListingsLast30Days': newListingsSnapshot.count,
      'chatSessionsLast30Days': chatSessionsSnapshot.count,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> getUserStats() async {
    final usersSnapshot = await _firestore.collection('users').get();

    int verifiedUsers = 0;
    int suspendedUsers = 0;

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      if (data['isVerified'] == true) verifiedUsers++;
      if (data['isSuspended'] == true) suspendedUsers++;
    }

    return {
      'totalUsers': usersSnapshot.size,
      'verifiedUsers': verifiedUsers,
      'suspendedUsers': suspendedUsers,
      'activeUsers': usersSnapshot.size - suspendedUsers,
    };
  }

  Future<Map<String, dynamic>> getListingStats() async {
    final listingsSnapshot = await _firestore.collection('listings').get();

    int activeListings = 0;
    int pendingListings = 0;
    int rejectedListings = 0;
    int premiumListings = 0;
    int totalViews = 0;

    final brandCounts = <String, int>{};

    for (final doc in listingsSnapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String?;
      final isPremium = data['isPremium'] as bool? ?? false;
      final views = data['viewCount'] as int? ?? 0;
      final brand = data['brand'] as String? ?? 'Unknown';

      if (status == 'active') activeListings++;
      if (status == 'pending') pendingListings++;
      if (status == 'rejected') rejectedListings++;
      if (isPremium) premiumListings++;

      totalViews += views;
      brandCounts[brand] = (brandCounts[brand] ?? 0) + 1;
    }

    // Get top 5 brands
    final topBrands = brandCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalListings': listingsSnapshot.size,
      'activeListings': activeListings,
      'pendingListings': pendingListings,
      'rejectedListings': rejectedListings,
      'premiumListings': premiumListings,
      'totalViews': totalViews,
      'topBrands': topBrands.take(5).map((e) => {
            'brand': e.key,
            'count': e.value,
          }).toList(),
    };
  }

  Future<Map<String, dynamic>> getChatStats() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final totalChatsCount =
        await _firestore.collection('chatSessions').count().get();

    final recentChatsSnapshot = await _firestore
        .collection('chatSessions')
        .where('createdAt', isGreaterThan: thirtyDaysAgo)
        .count()
        .get();

    // Get total messages count (approximate)
    final messagesCount = await _firestore
        .collectionGroup('messages')
        .count()
        .get();

    return {
      'totalChatSessions': totalChatsCount.count,
      'chatSessionsLast30Days': recentChatsSnapshot.count,
      'totalMessages': messagesCount.count,
    };
  }

  // User Management
  Future<void> suspendUser(String userId, String reason) async {
    await _firestore.collection('users').doc(userId).update({
      'isSuspended': true,
      'suspensionReason': reason,
      'suspendedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unsuspendUser(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'isSuspended': false,
      'suspensionReason': FieldValue.delete(),
      'suspendedAt': FieldValue.delete(),
      'unsuspendedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> verifyUser(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'isVerified': true,
      'verifiedAt': FieldValue.serverTimestamp(),
      'verificationExpiresAt': DateTime.now()
          .add(const Duration(days: 365))
          .toIso8601String(),
    });
  }

  Future<void> unverifyUser(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'isVerified': false,
      'verifiedAt': FieldValue.delete(),
      'verificationExpiresAt': FieldValue.delete(),
    });
  }

  // Reports
  Future<void> resolveReport(String reportId) async {
    await _firestore.collection('reports').doc(reportId).update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> dismissReport(String reportId) async {
    await _firestore.collection('reports').doc(reportId).update({
      'status': 'dismissed',
      'dismissedAt': FieldValue.serverTimestamp(),
    });
  }
}
