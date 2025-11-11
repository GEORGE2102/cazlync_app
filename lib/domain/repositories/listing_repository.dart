import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/listing_entity.dart';
import '../entities/listing_filter.dart';

abstract class ListingRepository {
  Future<Either<Failure, List<ListingEntity>>> getListings({
    ListingFilter? filter,
    int limit = 20,
    String? lastDocumentId,
  });
  
  Future<Either<Failure, ListingEntity>> getListingById(String id);
  
  Future<Either<Failure, String>> createListing(
    ListingEntity listing,
    List<String> imagePaths,
  );
  
  Future<Either<Failure, void>> updateListing(
    String id,
    Map<String, dynamic> updates,
  );
  
  Future<Either<Failure, void>> deleteListing(String id);
  
  Stream<List<ListingEntity>> watchListings({ListingFilter? filter});
  
  Future<Either<Failure, void>> incrementViewCount(String listingId);
  
  // Favorites methods
  Future<Either<Failure, void>> toggleFavorite(String userId, String listingId);
  
  Future<Either<Failure, List<String>>> getFavoriteIds(String userId);
  
  Future<Either<Failure, List<ListingEntity>>> getFavoriteListings(String userId);
  
  Stream<List<String>> watchFavoriteIds(String userId);
}
