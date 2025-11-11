import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/listing_entity.dart';

part 'favorites_state.freezed.dart';

@freezed
class FavoritesState with _$FavoritesState {
  const factory FavoritesState({
    @Default([]) List<ListingEntity> favorites,
    @Default([]) List<String> favoriteIds,
    @Default(false) bool isLoading,
    String? error,
  }) = _FavoritesState;
}
