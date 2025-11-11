import '../../domain/entities/listing_entity.dart';

class FavoritesState {
  final List<ListingEntity> favorites;
  final List<String> favoriteIds;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favorites = const [],
    this.favoriteIds = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<ListingEntity>? favorites,
    List<String>? favoriteIds,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
