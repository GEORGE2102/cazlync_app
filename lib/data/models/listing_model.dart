import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/listing_entity.dart';

class ListingModel extends ListingEntity {
  const ListingModel({
    required super.id,
    required super.sellerId,
    required super.brand,
    required super.model,
    required super.year,
    required super.price,
    required super.mileage,
    required super.description,
    required super.imageUrls,
    super.status,
    super.isPremium,
    required super.createdAt,
    super.premiumExpiresAt,
    super.specifications,
    super.viewCount,
    super.bodyType,
    super.condition,
    super.transmissionType,
    super.fuelType,
    super.location,
  });

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListingModel(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      mileage: data['mileage'] ?? 0,
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      status: _statusFromString(data['status'] ?? 'pending'),
      isPremium: data['isPremium'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      premiumExpiresAt: data['premiumExpiresAt'] != null
          ? (data['premiumExpiresAt'] as Timestamp).toDate()
          : null,
      specifications: Map<String, dynamic>.from(data['specifications'] ?? {}),
      viewCount: data['viewCount'] ?? 0,
      bodyType: data['bodyType'] != null ? _bodyTypeFromString(data['bodyType']) : null,
      condition: data['condition'] != null ? _conditionFromString(data['condition']) : null,
      transmissionType: data['transmissionType'] != null ? _transmissionFromString(data['transmissionType']) : null,
      fuelType: data['fuelType'] != null ? _fuelTypeFromString(data['fuelType']) : null,
      location: data['location'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'mileage': mileage,
      'description': description,
      'imageUrls': imageUrls,
      'status': status.name,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'premiumExpiresAt': premiumExpiresAt != null
          ? Timestamp.fromDate(premiumExpiresAt!)
          : null,
      'specifications': specifications,
      'viewCount': viewCount,
      'bodyType': bodyType?.name,
      'condition': condition?.name,
      'transmissionType': transmissionType?.name,
      'fuelType': fuelType?.name,
      'location': location,
    };
  }

  factory ListingModel.fromEntity(ListingEntity entity) {
    return ListingModel(
      id: entity.id,
      sellerId: entity.sellerId,
      brand: entity.brand,
      model: entity.model,
      year: entity.year,
      price: entity.price,
      mileage: entity.mileage,
      description: entity.description,
      imageUrls: entity.imageUrls,
      status: entity.status,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      premiumExpiresAt: entity.premiumExpiresAt,
      specifications: entity.specifications,
      viewCount: entity.viewCount,
      bodyType: entity.bodyType,
      condition: entity.condition,
      transmissionType: entity.transmissionType,
      fuelType: entity.fuelType,
      location: entity.location,
    );
  }

  ListingEntity toEntity() {
    return ListingEntity(
      id: id,
      sellerId: sellerId,
      brand: brand,
      model: model,
      year: year,
      price: price,
      mileage: mileage,
      description: description,
      imageUrls: imageUrls,
      status: status,
      isPremium: isPremium,
      createdAt: createdAt,
      premiumExpiresAt: premiumExpiresAt,
      specifications: specifications,
      viewCount: viewCount,
      bodyType: bodyType,
      condition: condition,
      transmissionType: transmissionType,
      fuelType: fuelType,
      location: location,
    );
  }

  static ListingStatus _statusFromString(String status) {
    switch (status) {
      case 'active':
        return ListingStatus.active;
      case 'rejected':
        return ListingStatus.rejected;
      case 'deleted':
        return ListingStatus.deleted;
      default:
        return ListingStatus.pending;
    }
  }

  static BodyType _bodyTypeFromString(String type) {
    switch (type) {
      case 'sedan':
        return BodyType.sedan;
      case 'coupe':
        return BodyType.coupe;
      case 'suv':
        return BodyType.suv;
      case 'hatchback':
        return BodyType.hatchback;
      case 'convertible':
        return BodyType.convertible;
      case 'pickup':
        return BodyType.pickup;
      case 'van':
        return BodyType.van;
      case 'wagon':
        return BodyType.wagon;
      default:
        return BodyType.other;
    }
  }

  static VehicleCondition _conditionFromString(String condition) {
    switch (condition) {
      case 'brandNew':
        return VehicleCondition.brandNew;
      case 'used':
        return VehicleCondition.used;
      case 'certifiedPreOwned':
        return VehicleCondition.certifiedPreOwned;
      default:
        return VehicleCondition.used;
    }
  }

  static TransmissionType _transmissionFromString(String transmission) {
    switch (transmission) {
      case 'automatic':
        return TransmissionType.automatic;
      case 'manual':
        return TransmissionType.manual;
      case 'cvt':
        return TransmissionType.cvt;
      case 'dct':
        return TransmissionType.dct;
      default:
        return TransmissionType.manual;
    }
  }

  static FuelType _fuelTypeFromString(String fuel) {
    switch (fuel) {
      case 'petrol':
        return FuelType.petrol;
      case 'diesel':
        return FuelType.diesel;
      case 'electric':
        return FuelType.electric;
      case 'hybrid':
        return FuelType.hybrid;
      case 'pluginHybrid':
        return FuelType.pluginHybrid;
      case 'lpg':
        return FuelType.lpg;
      default:
        return FuelType.petrol;
    }
  }

  @override
  ListingModel copyWith({
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
    return ListingModel(
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
