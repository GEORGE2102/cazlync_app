import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/entities/listing_filter.dart';
import '../../domain/repositories/listing_repository.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';
import '../services/image_upload_service.dart';

class ListingRepositoryImpl implements ListingRepository {
  final ListingService _listingService;
  final ImageUploadService _imageUploadService;

  ListingRepositoryImpl({
    required ListingService listingService,
    required ImageUploadService imageUploadService,
  })  : _listingService = listingService,
        _imageUploadService = imageUploadService;

  @override
  Future<Either<Failure, List<ListingEntity>>> getListings({
    ListingFilter? filter,
    int limit = 20,
    String? lastDocumentId,
  }) async {
    try {
      final listings = await _listingService.getListings(
        filter: filter,
        limit: limit,
      );
      return Right(listings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ListingEntity>> getListingById(String id) async {
    try {
      final listing = await _listingService.getListingById(id);
      return Right(listing);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createListing(
    ListingEntity listing,
    List<String> imagePaths,
  ) async {
    String? listingId;
    try {
      // Create listing first to get ID
      final listingModel = ListingModel.fromEntity(listing);
      listingId = await _listingService.createListing(listingModel);

      // Upload images - this is the critical step
      final imageUrls = await _imageUploadService.uploadListingImages(
        listingId,
        imagePaths,
      );

      // Update listing with image URLs
      await _listingService.updateListing(listingId, {
        'imageUrls': imageUrls,
      });

      return Right(listingId);
    } catch (e) {
      // If image upload fails, delete the listing to avoid orphaned data
      if (listingId != null) {
        try {
          await _listingService.deleteListing(listingId);
        } catch (_) {
          // Ignore cleanup errors
        }
      }
      return Left(ServerFailure('Failed to create listing: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateListing(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _listingService.updateListing(id, updates);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteListing(String id) async {
    try {
      await _listingService.deleteListing(id);
      await _imageUploadService.deleteListingImages(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<ListingEntity>> watchListings({ListingFilter? filter}) {
    return _listingService.watchListings(filter: filter);
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String listingId) async {
    try {
      await _listingService.incrementViewCount(listingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(
    String userId,
    String listingId,
  ) async {
    try {
      await _listingService.toggleFavorite(userId, listingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getFavoriteIds(String userId) async {
    try {
      final favoriteIds = await _listingService.getFavoriteIds(userId);
      return Right(favoriteIds);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getFavoriteListings(
    String userId,
  ) async {
    try {
      final listings = await _listingService.getFavoriteListings(userId);
      return Right(listings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<String>> watchFavoriteIds(String userId) {
    return _listingService.watchFavoriteIds(userId);
  }
}
