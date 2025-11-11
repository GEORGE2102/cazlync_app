import 'package:equatable/equatable.dart';
import '../../domain/entities/listing_entity.dart';

enum ListingStateStatus { initial, loading, success, error }

class ListingState extends Equatable {
  final ListingStateStatus status;
  final List<ListingEntity> listings;
  final String? errorMessage;
  final bool hasMore;
  final bool isLoadingMore;

  const ListingState({
    this.status = ListingStateStatus.initial,
    this.listings = const [],
    this.errorMessage,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        status,
        listings,
        errorMessage,
        hasMore,
        isLoadingMore,
      ];

  ListingState copyWith({
    ListingStateStatus? status,
    List<ListingEntity>? listings,
    String? errorMessage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ListingState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ListingDetailState extends Equatable {
  final ListingStateStatus status;
  final ListingEntity? listing;
  final String? errorMessage;

  const ListingDetailState({
    this.status = ListingStateStatus.initial,
    this.listing,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, listing, errorMessage];

  ListingDetailState copyWith({
    ListingStateStatus? status,
    ListingEntity? listing,
    String? errorMessage,
  }) {
    return ListingDetailState(
      status: status ?? this.status,
      listing: listing ?? this.listing,
      errorMessage: errorMessage,
    );
  }
}

class CreateListingState extends Equatable {
  final ListingStateStatus status;
  final String? errorMessage;
  final String? listingId;

  const CreateListingState({
    this.status = ListingStateStatus.initial,
    this.errorMessage,
    this.listingId,
  });

  @override
  List<Object?> get props => [status, errorMessage, listingId];

  CreateListingState copyWith({
    ListingStateStatus? status,
    String? errorMessage,
    String? listingId,
  }) {
    return CreateListingState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      listingId: listingId,
    );
  }
}
