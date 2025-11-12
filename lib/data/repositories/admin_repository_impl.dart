import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../services/admin_service.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminService _adminService;

  AdminRepositoryImpl({required AdminService adminService})
      : _adminService = adminService;

  @override
  Future<Either<Failure, void>> approveListing(String listingId) async {
    try {
      await _adminService.approveListing(listingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectListing(
    String listingId,
    String reason,
  ) async {
    try {
      await _adminService.rejectListing(listingId, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeListing(String listingId) async {
    try {
      await _adminService.removeListing(listingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getPendingListings() async {
    try {
      final listings = await _adminService.getPendingListings();
      return Right(listings.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getReportedListings() async {
    try {
      final listings = await _adminService.getReportedListings();
      return Right(listings.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAnalytics() async {
    try {
      final analytics = await _adminService.getAnalytics();
      return Right(analytics);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserStats() async {
    try {
      final stats = await _adminService.getUserStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getListingStats() async {
    try {
      final stats = await _adminService.getListingStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getChatStats() async {
    try {
      final stats = await _adminService.getChatStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> suspendUser(
    String userId,
    String reason,
  ) async {
    try {
      await _adminService.suspendUser(userId, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unsuspendUser(String userId) async {
    try {
      await _adminService.unsuspendUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyUser(String userId) async {
    try {
      await _adminService.verifyUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unverifyUser(String userId) async {
    try {
      await _adminService.unverifyUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resolveReport(String reportId) async {
    try {
      await _adminService.resolveReport(reportId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> dismissReport(String reportId) async {
    try {
      await _adminService.dismissReport(reportId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
