import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../entities/listing_entity.dart';

abstract class ProfileRepository {
  // User profile methods
  Future<Either<Failure, UserEntity>> getUserProfile(String userId);
  
  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  });
  
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String userId,
    required String imagePath,
  });
  
  // User listings methods
  Future<Either<Failure, List<ListingEntity>>> getUserListings(String userId);
  
  Future<Either<Failure, void>> deleteUserListing(String listingId);
  
  // Statistics
  Future<Either<Failure, Map<String, int>>> getUserStats(String userId);
}
