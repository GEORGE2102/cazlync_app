import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/entities/listing_filter.dart';
import '../../domain/repositories/listing_repository.dart';
import 'listing_state.dart';

class ListingController extends StateNotifier<ListingState> {
  final ListingRepository _repository;
  ListingFilter? _currentFilter;

  ListingController(this._repository) : super(const ListingState());

  Future<void> loadListings({ListingFilter? filter}) async {
    _currentFilter = filter;
    state = state.copyWith(status: ListingStateStatus.loading);

    final result = await _repository.getListings(filter: filter);

    result.fold(
      (failure) => state = state.copyWith(
        status: ListingStateStatus.error,
        errorMessage: failure.message,
      ),
      (listings) => state = state.copyWith(
        status: ListingStateStatus.success,
        listings: listings,
        hasMore: listings.length >= 20,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await _repository.getListings(
      filter: _currentFilter,
      lastDocumentId: state.listings.isNotEmpty ? state.listings.last.id : null,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.message,
      ),
      (newListings) {
        final allListings = [...state.listings, ...newListings];
        state = state.copyWith(
          listings: allListings,
          isLoadingMore: false,
          hasMore: newListings.length >= 20,
        );
      },
    );
  }

  Future<void> refresh() async {
    await loadListings(filter: _currentFilter);
  }
}

class ListingDetailController extends StateNotifier<ListingDetailState> {
  final ListingRepository _repository;

  ListingDetailController(this._repository)
      : super(const ListingDetailState());

  Future<void> loadListing(String id) async {
    state = state.copyWith(status: ListingStateStatus.loading);

    final result = await _repository.getListingById(id);

    result.fold(
      (failure) => state = state.copyWith(
        status: ListingStateStatus.error,
        errorMessage: failure.message,
      ),
      (listing) {
        state = state.copyWith(
          status: ListingStateStatus.success,
          listing: listing,
        );
        // Increment view count
        _repository.incrementViewCount(id);
      },
    );
  }
}

class CreateListingController extends StateNotifier<CreateListingState> {
  final ListingRepository _repository;

  CreateListingController(this._repository)
      : super(const CreateListingState());

  Future<void> createListing(
    ListingEntity listing,
    List<String> imagePaths,
  ) async {
    state = state.copyWith(status: ListingStateStatus.loading);

    final result = await _repository.createListing(listing, imagePaths);

    result.fold(
      (failure) => state = state.copyWith(
        status: ListingStateStatus.error,
        errorMessage: failure.message,
      ),
      (listingId) => state = state.copyWith(
        status: ListingStateStatus.success,
        listingId: listingId,
      ),
    );
  }

  Future<void> updateListing(
    String id,
    Map<String, dynamic> updates,
  ) async {
    state = state.copyWith(status: ListingStateStatus.loading);

    final result = await _repository.updateListing(id, updates);

    result.fold(
      (failure) => state = state.copyWith(
        status: ListingStateStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: ListingStateStatus.success,
      ),
    );
  }

  Future<void> deleteListing(String id) async {
    state = state.copyWith(status: ListingStateStatus.loading);

    final result = await _repository.deleteListing(id);

    result.fold(
      (failure) => state = state.copyWith(
        status: ListingStateStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: ListingStateStatus.success,
      ),
    );
  }

  void reset() {
    state = const CreateListingState();
  }
}
