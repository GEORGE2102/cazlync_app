import 'package:equatable/equatable.dart';

enum ListingStatus {
  pending,
  active,
  rejected,
  deleted,
}

enum BodyType {
  sedan,
  coupe,
  suv,
  hatchback,
  convertible,
  pickup,
  van,
  wagon,
  other,
}

enum VehicleCondition {
  brandNew,
  used,
  certifiedPreOwned,
}

enum TransmissionType {
  automatic,
  manual,
  cvt,
  dct,
}

enum FuelType {
  petrol,
  diesel,
  electric,
  hybrid,
  pluginHybrid,
  lpg,
}

class ListingEntity extends Equatable {
  final String id;
  final String sellerId;
  final String brand;
  final String model;
  final int year;
  final double price;
  final int mileage;
  final String description;
  final List<String> imageUrls;
  final ListingStatus status;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? premiumExpiresAt;
  final Map<String, dynamic> specifications;
  final int viewCount;
  final BodyType? bodyType;
  final VehicleCondition? condition;
  final TransmissionType? transmissionType;
  final FuelType? fuelType;
  final String? location;

  const ListingEntity({
    required this.id,
    required this.sellerId,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.mileage,
    required this.description,
    required this.imageUrls,
    this.status = ListingStatus.pending, // Listings require admin approval
    this.isPremium = false,
    required this.createdAt,
    this.premiumExpiresAt,
    this.specifications = const {},
    this.viewCount = 0,
    this.bodyType,
    this.condition,
    this.transmissionType,
    this.fuelType,
    this.location,
  });

  @override
  List<Object?> get props => [
        id,
        sellerId,
        brand,
        model,
        year,
        price,
        mileage,
        description,
        imageUrls,
        status,
        isPremium,
        createdAt,
        premiumExpiresAt,
        specifications,
        viewCount,
        bodyType,
        condition,
        transmissionType,
        fuelType,
        location,
      ];

  ListingEntity copyWith({
    String? id,
    String? sellerId,
    String? brand,
    String? model,
    int? year,
    double? price,
    int? mileage,
    String? description,
    List<String>? imageUrls,
    ListingStatus? status,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? premiumExpiresAt,
    Map<String, dynamic>? specifications,
    int? viewCount,
    BodyType? bodyType,
    VehicleCondition? condition,
    TransmissionType? transmissionType,
    FuelType? fuelType,
    String? location,
  }) {
    return ListingEntity(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      price: price ?? this.price,
      mileage: mileage ?? this.mileage,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      specifications: specifications ?? this.specifications,
      viewCount: viewCount ?? this.viewCount,
      bodyType: bodyType ?? this.bodyType,
      condition: condition ?? this.condition,
      transmissionType: transmissionType ?? this.transmissionType,
      fuelType: fuelType ?? this.fuelType,
      location: location ?? this.location,
    );
  }
}
