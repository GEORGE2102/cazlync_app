import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/listing_repository.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../../domain/entities/listing_filter.dart';
import '../../domain/entities/listing_entity.dart';
import 'search_state.dart';
import 'listing_state.dart';

class SearchController extends StateNotifier<SearchState> {
  final ListingRepositoryImpl _listingRepository;
  Timer? _debounce;

  SearchController({
    required ListingRepositoryImpl listingRepository,
  })  : _listingRepository = listingRepository,
        super(const SearchState());

  void search(String query) {
    // Cancel previous debounce timer
    _debounce?.cancel();

    // Update search query immediately
    state = state.copyWith(searchQuery: query);

    // Debounce the actual search
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    if (state.searchQuery.isEmpty && !state.filters.hasActiveFilters) {
      state = state.copyWith(
        status: ListingStateStatus.initial,
        listings: [],
      );
      return;
    }

    state = state.copyWith(status: ListingStateStatus.loading);

    final result = await _listingRepository.getListings(
      filter: state.filters.copyWith(searchQuery: state.searchQuery),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ListingStateStatus.error,
          errorMessage: failure.message,
        );
      },
      (listings) {
        state = state.copyWith(
          status: ListingStateStatus.success,
          listings: listings,
        );
      },
    );
  }

  void clearSearch() {
    _debounce?.cancel();
    state = state.copyWith(
      searchQuery: '',
      status: ListingStateStatus.initial,
      listings: [],
    );
  }

  void updateBrand(String? brand) {
    state = state.copyWith(
      filters: state.filters.copyWith(brand: brand),
    );
    _performSearch();
  }

  void updateModel(String? model) {
    state = state.copyWith(
      filters: state.filters.copyWith(model: model),
    );
    _performSearch();
  }

  void updatePriceRange(int? minPrice, int? maxPrice) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        minPrice: minPrice?.toDouble(),
        maxPrice: maxPrice?.toDouble(),
      ),
    );
    _performSearch();
  }

  void updateYearRange(int? minYear, int? maxYear) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        minYear: minYear,
        maxYear: maxYear,
      ),
    );
    _performSearch();
  }

  void updateMaxMileage(int? maxMileage) {
    state = state.copyWith(
      filters: state.filters.copyWith(maxMileage: maxMileage),
    );
    _performSearch();
  }

  void updateCondition(String? conditionStr) {
    VehicleCondition? condition;
    if (conditionStr != null) {
      condition = conditionStr == 'New' ? VehicleCondition.brandNew : VehicleCondition.used;
    }
    state = state.copyWith(
      filters: state.filters.copyWith(
        condition: condition,
        clearCondition: conditionStr == null,
      ),
    );
    _performSearch();
  }

  void updateTransmission(String? transmissionStr) {
    TransmissionType? transmission;
    if (transmissionStr != null) {
      transmission = transmissionStr == 'Automatic' 
          ? TransmissionType.automatic 
          : TransmissionType.manual;
    }
    state = state.copyWith(
      filters: state.filters.copyWith(
        transmissionType: transmission,
        clearTransmissionType: transmissionStr == null,
      ),
    );
    _performSearch();
  }

  void updateFuelType(String? fuelTypeStr) {
    FuelType? fuelType;
    if (fuelTypeStr != null) {
      switch (fuelTypeStr) {
        case 'Petrol':
          fuelType = FuelType.petrol;
          break;
        case 'Diesel':
          fuelType = FuelType.diesel;
          break;
        case 'Electric':
          fuelType = FuelType.electric;
          break;
        case 'Hybrid':
          fuelType = FuelType.hybrid;
          break;
        case 'LPG':
          fuelType = FuelType.lpg;
          break;
      }
    }
    state = state.copyWith(
      filters: state.filters.copyWith(
        fuelType: fuelType,
        clearFuelType: fuelTypeStr == null,
      ),
    );
    _performSearch();
  }

  void clearFilters() {
    state = state.copyWith(
      filters: const ListingFilter(),
    );
    _performSearch();
  }

  void retry() {
    _performSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
