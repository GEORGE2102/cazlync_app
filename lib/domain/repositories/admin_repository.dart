import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/listing_entity.dart';

abstract class AdminRepository {
  // Listing Moderation
  Future<Either<Failure, void>> approveListing(String listingId);
  Future<Either<Failure, void>> rejectListing(
    String listingId,
    String reason,
  );
  Future<Either<Failure, void>> removeListing(String listingId);
  Future<Either<Failure, List<ListingEntity>>> getPendingListings();
  Future<Either<Failure, List<ListingEntity>>> getReportedListings();

  // Analytics
  Future<Either<Failure, Map<String, dynamic>>> getAnalytics();
  Future<Either<Failure, Map<String, dynamic>>> getUserStats();
  Future<Either<Failure, Map<String, dynamic>>> getListingStats();
  Future<Either<Failure, Map<String, dynamic>>> getChatStats();

  // User Management
  Future<Either<Failure, void>> suspendUser(String userId, String reason);
  Future<Either<Failure, void>> unsuspendUser(String userId);
  Future<Either<Failure, void>> verifyUser(String userId);
  Future<Either<Failure, void>> unverifyUser(String userId);

  // Reports
  Future<Either<Failure, void>> resolveReport(String reportId);
  Future<Either<Failure, void>> dismissReport(String reportId);
}
