import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_state.dart';

class AdminController extends StateNotifier<AdminState> {
  final AdminRepository _adminRepository;

  AdminController({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(const AdminState()) {
    // Start listening to real-time updates
    _initializeRealTimeListeners();
  }

  // Initialize real-time listeners
  void _initializeRealTimeListeners() {
    // Listen to pending listings in real-time
    _adminRepository.watchPendingListings().listen((listings) {
      state = state.copyWith(pendingListings: listings);
    });

    // Listen to listing counts in real-time
    _adminRepository.watchListingCounts().listen((counts) {
      final currentStats = Map<String, dynamic>.from(state.listingStats ?? {});
      currentStats['activeListings'] = counts['active'];
      currentStats['pendingListings'] = counts['pending'];
      currentStats['totalListings'] = counts['total'];
      state = state.copyWith(listingStats: currentStats);
    });

    // Listen to user count in real-time
    _adminRepository.watchUserCount().listen((count) {
      final currentStats = Map<String, dynamic>.from(state.userStats ?? {});
      currentStats['totalUsers'] = count;
      state = state.copyWith(userStats: currentStats);
    });
  }

  // Load all admin data
  Future<void> loadAdminData() async {
    state = state.copyWith(status: AdminStatus.loading);

    await Future.wait([
      loadPendingListings(),
      loadAnalytics(),
      loadUserStats(),
      loadListingStats(),
      loadChatStats(),
    ]);

    state = state.copyWith(status: AdminStatus.success);
  }

  // Listing Moderation
  Future<void> loadPendingListings() async {
    final result = await _adminRepository.getPendingListings();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
      },
      (listings) {
        state = state.copyWith(
          pendingListings: listings,
        );
      },
    );
  }

  Future<void> loadReportedListings() async {
    final result = await _adminRepository.getReportedListings();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
      },
      (listings) {
        state = state.copyWith(
          reportedListings: listings,
        );
      },
    );
  }

  Future<bool> approveListing(String listingId) async {
    final result = await _adminRepository.approveListing(listingId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        // Remove from pending list
        final updatedPending = state.pendingListings
            .where((listing) => listing.id != listingId)
            .toList();

        state = state.copyWith(
          pendingListings: updatedPending,
          status: AdminStatus.success,
        );
        return true;
      },
    );
  }

  Future<bool> rejectListing(String listingId, String reason) async {
    final result = await _adminRepository.rejectListing(listingId, reason);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        // Remove from pending list
        final updatedPending = state.pendingListings
            .where((listing) => listing.id != listingId)
            .toList();

        state = state.copyWith(
          pendingListings: updatedPending,
          status: AdminStatus.success,
        );
        return true;
      },
    );
  }

  Future<bool> removeListing(String listingId) async {
    final result = await _adminRepository.removeListing(listingId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        // Remove from reported list
        final updatedReported = state.reportedListings
            .where((listing) => listing.id != listingId)
            .toList();

        state = state.copyWith(
          reportedListings: updatedReported,
          status: AdminStatus.success,
        );
        return true;
      },
    );
  }

  // Analytics
  Future<void> loadAnalytics() async {
    final result = await _adminRepository.getAnalytics();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
      },
      (analytics) {
        state = state.copyWith(
          analytics: analytics,
        );
      },
    );
  }

  Future<void> loadUserStats() async {
    final result = await _adminRepository.getUserStats();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
      },
      (stats) {
        state = state.copyWith(
          userStats: stats,
        );
      },
    );
  }

  Future<void> loadListingStats() async {
    final result = await _adminRepository.getListingStats();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
      },
      (stats) {
        state = state.copyWith(
          listingStats: stats,
        );
      },
    );
  }

  Future<void> loadChatStats() async {
    final result = await _adminRepository.getChatStats();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
      },
      (stats) {
        state = state.copyWith(
          chatStats: stats,
        );
      },
    );
  }

  // User Management
  Future<bool> suspendUser(String userId, String reason) async {
    final result = await _adminRepository.suspendUser(userId, reason);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: AdminStatus.success);
        return true;
      },
    );
  }

  Future<bool> unsuspendUser(String userId) async {
    final result = await _adminRepository.unsuspendUser(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: AdminStatus.success);
        return true;
      },
    );
  }

  Future<bool> verifyUser(String userId) async {
    final result = await _adminRepository.verifyUser(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: AdminStatus.success);
        return true;
      },
    );
  }

  // Reports
  Future<bool> resolveReport(String reportId) async {
    final result = await _adminRepository.resolveReport(reportId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: AdminStatus.success);
        return true;
      },
    );
  }

  Future<bool> dismissReport(String reportId) async {
    final result = await _adminRepository.dismissReport(reportId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AdminStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(status: AdminStatus.success);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
