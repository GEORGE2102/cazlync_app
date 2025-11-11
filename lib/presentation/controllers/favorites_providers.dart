import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../../data/services/listing_service.dart';
import '../../data/services/image_upload_service.dart';
import 'favorites_controller.dart';
import 'favorites_state.dart';
import 'auth_providers.dart';

final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, FavoritesState>((ref) {
  final listingService = ListingService();
  final imageUploadService = ImageUploadService();
  final listingRepository = ListingRepositoryImpl(
    listingService: listingService,
    imageUploadService: imageUploadService,
  );

  final controller = FavoritesController(
    listingRepository: listingRepository,
    ref: ref,
  );

  // Watch favorite IDs in real-time
  controller.watchFavoriteIds();

  return controller;
});

// Provider for just the favorite IDs (for checking if a listing is favorited)
final favoriteIdsProvider = Provider<List<String>>((ref) {
  final state = ref.watch(favoritesControllerProvider);
  return state.favoriteIds;
});

// Provider to check if a specific listing is favorited
final isFavoriteProvider = Provider.family<bool, String>((ref, listingId) {
  final favoriteIds = ref.watch(favoriteIdsProvider);
  return favoriteIds.contains(listingId);
});
