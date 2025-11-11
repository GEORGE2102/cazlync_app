import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../services/profile_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl({required ProfileService profileService})
      : _profileService = profileService;

  @override
  Future<Either<Failure, UserEntity>> getUserProfile(String userId) async {
    try {
      final user = await _profileService.getUserProfile(userId);
      return Right(user.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      await _profileService.updateProfile(
        userId: userId,
        displayName: displayName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String userId,
    required String imagePath,
  }) async {
    try {
      final photoUrl = await _profileService.uploadProfilePhoto(
        userId: userId,
        imagePath: imagePath,
      );
      return Right(photoUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getUserListings(
    String userId,
  ) async {
    try {
      final listings = await _profileService.getUserListings(userId);
      return Right(listings.map((l) => l.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserListing(String listingId) async {
    try {
      await _profileService.deleteUserListing(listingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getUserStats(String userId) async {
    try {
      final stats = await _profileService.getUserStats(userId);
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
