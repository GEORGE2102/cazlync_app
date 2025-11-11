import 'package:equatable/equatable.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/entities/listing_filter.dart';
import 'listing_state.dart';

class SearchState extends Equatable {
  final ListingStateStatus status;
  final List<ListingEntity> listings;
  final String? errorMessage;
  final String searchQuery;
  final ListingFilter filters;

  const SearchState({
    this.status = ListingStateStatus.initial,
    this.listings = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.filters = const ListingFilter(),
  });

  @override
  List<Object?> get props => [
        status,
        listings,
        errorMessage,
        searchQuery,
        filters,
      ];

  SearchState copyWith({
    ListingStateStatus? status,
    List<ListingEntity>? listings,
    String? errorMessage,
    String? searchQuery,
    ListingFilter? filters,
  }) {
    return SearchState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
    );
  }
}
