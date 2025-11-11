import 'package:equatable/equatable.dart';
import 'listing_entity.dart';

class ListingFilter extends Equatable {
  final String? brand;
  final String? model;
  final double? minPrice;
  final double? maxPrice;
  final int? minYear;
  final int? maxYear;
  final int? minMileage;
  final int? maxMileage;
  final String? searchQuery;
  final BodyType? bodyType;
  final VehicleCondition? condition;
  final TransmissionType? transmissionType;
  final FuelType? fuelType;
  final String? location;

  const ListingFilter({
    this.brand,
    this.model,
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.minMileage,
    this.maxMileage,
    this.searchQuery,
    this.bodyType,
    this.condition,
    this.transmissionType,
    this.fuelType,
    this.location,
  });

  bool get hasFilters =>
      brand != null ||
      model != null ||
      minPrice != null ||
      maxPrice != null ||
      minYear != null ||
      maxYear != null ||
      minMileage != null ||
      maxMileage != null ||
      searchQuery != null ||
      bodyType != null ||
      condition != null ||
      transmissionType != null ||
      fuelType != null ||
      location != null;

  @override
  List<Object?> get props => [
        brand,
        model,
        minPrice,
        maxPrice,
        minYear,
        maxYear,
        minMileage,
        maxMileage,
        searchQuery,
        bodyType,
        condition,
        transmissionType,
        fuelType,
        location,
      ];

  ListingFilter copyWith({
    String? brand,
    String? model,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    int? minMileage,
    int? maxMileage,
    String? searchQuery,
    BodyType? bodyType,
    VehicleCondition? condition,
    TransmissionType? transmissionType,
    FuelType? fuelType,
    String? location,
    bool clearBrand = false,
    bool clearModel = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMinYear = false,
    bool clearMaxYear = false,
    bool clearMinMileage = false,
    bool clearMaxMileage = false,
    bool clearSearchQuery = false,
    bool clearBodyType = false,
    bool clearCondition = false,
    bool clearTransmissionType = false,
    bool clearFuelType = false,
    bool clearLocation = false,
  }) {
    return ListingFilter(
      brand: clearBrand ? null : (brand ?? this.brand),
      model: clearModel ? null : (model ?? this.model),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      minYear: clearMinYear ? null : (minYear ?? this.minYear),
      maxYear: clearMaxYear ? null : (maxYear ?? this.maxYear),
      minMileage: clearMinMileage ? null : (minMileage ?? this.minMileage),
      maxMileage: clearMaxMileage ? null : (maxMileage ?? this.maxMileage),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      bodyType: clearBodyType ? null : (bodyType ?? this.bodyType),
      condition: clearCondition ? null : (condition ?? this.condition),
      transmissionType: clearTransmissionType ? null : (transmissionType ?? this.transmissionType),
      fuelType: clearFuelType ? null : (fuelType ?? this.fuelType),
      location: clearLocation ? null : (location ?? this.location),
    );
  }

  ListingFilter clear() {
    return const ListingFilter();
  }
}
