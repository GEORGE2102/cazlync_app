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

    // Apply filters
    query = query.where('status', isEqualTo: 'active');

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
}
