import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/repositories/profile_repository_impl.dart';
import 'profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  final ProfileRepositoryImpl _profileRepository;

  ProfileController({
    required ProfileRepositoryImpl profileRepository,
  })  : _profileRepository = profileRepository,
        super(const ProfileState());

  Future<void> loadUserProfile(String userId) async {
    state = state.copyWith(status: ProfileStatus.loading);

    final result = await _profileRepository.getUserProfile(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: ProfileStatus.success,
          user: user,
        );
      },
    );
  }

  Future<void> loadUserListings(String userId) async {
    final result = await _profileRepository.getUserListings(userId);

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (listings) {
        state = state.copyWith(userListings: listings);
      },
    );
  }

  Future<void> loadUserStats(String userId) async {
    final result = await _profileRepository.getUserStats(userId);

    result.fold(
      (failure) {
        // Silently fail for stats
      },
      (stats) {
        state = state.copyWith(stats: stats);
      },
    );
  }

  Future<bool> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isUpdating: true);

    final result = await _profileRepository.updateProfile(
      userId: userId,
      displayName: displayName,
      phoneNumber: phoneNumber,
    );

    state = state.copyWith(isUpdating: false);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        // Reload profile to get updated data
        loadUserProfile(userId);
        return true;
      },
    );
  }

  Future<String?> uploadProfilePhoto({
    required String userId,
    required String imagePath,
  }) async {
    state = state.copyWith(isUpdating: true);

    final result = await _profileRepository.uploadProfilePhoto(
      userId: userId,
      imagePath: imagePath,
    );

    state = state.copyWith(isUpdating: false);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return null;
      },
      (photoUrl) {
        // Reload profile to get updated photo
        loadUserProfile(userId);
        return photoUrl;
      },
    );
  }

  Future<bool> deleteListing(String listingId, String userId) async {
    final result = await _profileRepository.deleteUserListing(listingId);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        // Reload listings
        loadUserListings(userId);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
