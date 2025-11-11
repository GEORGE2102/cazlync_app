import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/listing_repository.dart';
import 'favorites_state.dart';
import 'auth_providers.dart';

class FavoritesController extends StateNotifier<FavoritesState> {
  final ListingRepository _listingRepository;
  final Ref _ref;

  FavoritesController({
    required ListingRepository listingRepository,
    required Ref ref,
  })  : _listingRepository = listingRepository,
        _ref = ref,
        super(const FavoritesState());

  Future<void> loadFavorites() async {
    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      state = state.copyWith(
        favorites: [],
        favoriteIds: [],
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    // Load favorite IDs
    final idsResult = await _listingRepository.getFavoriteIds(userId);
    idsResult.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (ids) {
        state = state.copyWith(favoriteIds: ids);
      },
    );

    // Load favorite listings
    final listingsResult = await _listingRepository.getFavoriteListings(userId);
    listingsResult.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (listings) {
        state = state.copyWith(
          favorites: listings,
          isLoading: false,
        );
      },
    );
  }

  Future<void> toggleFavorite(String listingId) async {
    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;

    if (userId == null) return;

    // Optimistic update
    final currentIds = List<String>.from(state.favoriteIds);
    final isFavorite = currentIds.contains(listingId);

    if (isFavorite) {
      currentIds.remove(listingId);
    } else {
      currentIds.add(listingId);
    }

    state = state.copyWith(favoriteIds: currentIds);

    // Perform actual toggle
    final result = await _listingRepository.toggleFavorite(userId, listingId);

    result.fold(
      (failure) {
        // Revert on failure
        if (isFavorite) {
          currentIds.add(listingId);
        } else {
          currentIds.remove(listingId);
        }
        state = state.copyWith(
          favoriteIds: currentIds,
          error: failure.message,
        );
      },
      (_) {
        // Reload favorites to sync
        loadFavorites();
      },
    );
  }

  void watchFavoriteIds() {
    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;

    if (userId == null) return;

    _listingRepository.watchFavoriteIds(userId).listen((ids) {
      state = state.copyWith(favoriteIds: ids);
    });
  }
}
