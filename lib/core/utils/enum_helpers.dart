import '../../domain/entities/listing_entity.dart';

class EnumHelpers {
  static String bodyTypeToString(BodyType type) {
    switch (type) {
      case BodyType.sedan:
        return 'Sedan';
      case BodyType.coupe:
        return 'Coupe';
      case BodyType.suv:
        return 'SUV';
      case BodyType.hatchback:
        return 'Hatchback';
      case BodyType.convertible:
        return 'Convertible';
      case BodyType.pickup:
        return 'Pickup';
      case BodyType.van:
        return 'Van';
      case BodyType.wagon:
        return 'Wagon';
      case BodyType.other:
        return 'Other';
    }
  }

  static String conditionToString(VehicleCondition condition) {
    switch (condition) {
      case VehicleCondition.brandNew:
        return 'Brand New';
      case VehicleCondition.used:
        return 'Used';
      case VehicleCondition.certifiedPreOwned:
        return 'Certified Pre-Owned';
    }
  }

  static String transmissionToString(TransmissionType transmission) {
    switch (transmission) {
      case TransmissionType.automatic:
        return 'Automatic';
      case TransmissionType.manual:
        return 'Manual';
      case TransmissionType.cvt:
        return 'CVT';
      case TransmissionType.dct:
        return 'DCT';
    }
  }

  static String fuelTypeToString(FuelType fuel) {
    switch (fuel) {
      case FuelType.petrol:
        return 'Petrol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      case FuelType.hybrid:
        return 'Hybrid';
      case FuelType.pluginHybrid:
        return 'Plug-in Hybrid';
      case FuelType.lpg:
        return 'LPG';
    }
  }

  static List<BodyType> get allBodyTypes => BodyType.values;
  static List<VehicleCondition> get allConditions => VehicleCondition.values;
  static List<TransmissionType> get allTransmissions => TransmissionType.values;
  static List<FuelType> get allFuelTypes => FuelType.values;
}
