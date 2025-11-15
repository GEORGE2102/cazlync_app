import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../../domain/entities/listing_filter.dart';

class ListingService {
  final FirebaseFirestore _firestore;

  ListingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ListingModel>> getListings({
    ListingFilter? filter,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore.collection('listings');

    // Apply filters - show both active and sold listings
    query = query.where('status', whereIn: ['active', 'sold']);

    if (filter != null) {
      if (filter.brand != null) {
        query = query.where('brand', isEqualTo: filter.brand);
      }
      if (filter.model != null) {
        query = query.where('model', isEqualTo: filter.model);
      }
    }

    // Sort premium listings first, then by creation date
    query = query.orderBy('isPremium', descending: true);
    query = query.orderBy('createdAt', descending: true);

    // Pagination
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    var listings = snapshot.docs
        .map((doc) => ListingModel.fromFirestore(doc))
        .toList();

    // Apply client-side filters
    if (filter != null) {
      listings = _applyClientFilters(listings, filter);
    }

    return listings;
  }

  List<ListingModel> _applyClientFilters(
    List<ListingModel> listings,
    ListingFilter filter,
  ) {
    return listings.where((listing) {
      if (filter.minPrice != null && listing.price < filter.minPrice!) {
        return false;
      }
      if (filter.maxPrice != null && listing.price > filter.maxPrice!) {
        return false;
      }
      if (filter.minYear != null && listing.year < filter.minYear!) {
        return false;
      }
      if (filter.maxYear != null && listing.year > filter.maxYear!) {
        return false;
      }
      if (filter.minMileage != null && listing.mileage < filter.minMileage!) {
        return false;
      }
      if (filter.maxMileage != null && listing.mileage > filter.maxMileage!) {
        return false;
      }
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        return listing.brand.toLowerCase().contains(query) ||
            listing.model.toLowerCase().contains(query) ||
            listing.description.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  Future<ListingModel> getListingById(String id) async {
    final doc = await _firestore.collection('listings').doc(id).get();
    
    if (!doc.exists) {
      throw Exception('Listing not found');
    }

    return ListingModel.fromFirestore(doc);
  }

  Future<String> createListing(ListingModel listing) async {
    final docRef = await _firestore.collection('listings').add(
      listing.toFirestore(),
    );
    return docRef.id;
  }

  Future<void> updateListing(String id, Map<String, dynamic> updates) async {
    await _firestore.collection('listings').doc(id).update(updates);
  }

  Future<void> deleteListing(String id) async {
    await _firestore.collection('listings').doc(id).update({
      'status': 'deleted',
    });
  }

  Stream<List<ListingModel>> watchListings({ListingFilter? filter}) {
    Query query = _firestore.collection('listings');

    query = query.where('status', isEqualTo: 'active');

    if (filter?.brand != null) {
      query = query.where('brand', isEqualTo: filter!.brand);
    }
    if (filter?.model != null) {
      query = query.where('model', isEqualTo: filter!.model);
    }

    query = query.orderBy('isPremium', descending: true);
    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      var listings = snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();

      if (filter != null) {
        listings = _applyClientFilters(listings, filter);
      }

      return listings;
    });
  }

  Future<void> incrementViewCount(String listingId) async {
    await _firestore.collection('listings').doc(listingId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

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

  // Favorites methods
  Future<void> toggleFavorite(String userId, String listingId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw Exception('User not found');
    }

    final userData = userDoc.data()!;
    final favorites = List<String>.from(userData['favoriteListings'] ?? []);

    if (favorites.contains(listingId)) {
      // Remove from favorites
      favorites.remove(listingId);
    } else {
      // Add to favorites
      favorites.add(listingId);
    }

    await userRef.update({'favoriteListings': favorites});
  }

  Future<List<String>> getFavoriteIds(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      return [];
    }

    final userData = userDoc.data()!;
    return List<String>.from(userData['favoriteListings'] ?? []);
  }

  Future<List<ListingModel>> getFavoriteListings(String userId) async {
    final favoriteIds = await getFavoriteIds(userId);

    if (favoriteIds.isEmpty) {
      return [];
    }

    // Firestore 'in' query has a limit of 10 items
    // Split into batches if needed
    final List<ListingModel> allListings = [];
    
    for (int i = 0; i < favoriteIds.length; i += 10) {
      final batch = favoriteIds.skip(i).take(10).toList();
      
      final snapshot = await _firestore
          .collection('listings')
          .where(FieldPath.documentId, whereIn: batch)
          .where('status', isEqualTo: 'active')
          .get();

      final listings = snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
      
      allListings.addAll(listings);
    }

    return allListings;
  }

  Stream<List<String>> watchFavoriteIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return <String>[];
      }
      final data = snapshot.data()!;
      return List<String>.from(data['favoriteListings'] ?? []);
    });
  }
}
