import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/services/profile_service.dart';
import 'profile_controller.dart';
import 'profile_state.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final profileService = ProfileService();
  final profileRepository = ProfileRepositoryImpl(profileService: profileService);

  return ProfileController(profileRepository: profileRepository);
});
