import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../../data/services/listing_service.dart';
import '../../data/services/image_upload_service.dart';
import 'search_controller.dart';
import 'search_state.dart';

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>((ref) {
  final listingService = ListingService();
  final imageUploadService = ImageUploadService();
  final listingRepository = ListingRepositoryImpl(
    listingService: listingService,
    imageUploadService: imageUploadService,
  );

  return SearchController(listingRepository: listingRepository);
});

// Provider to count active filters
final activeFiltersCountProvider = Provider<int>((ref) {
  final filters = ref.watch(searchControllerProvider).filters;
  int count = 0;

  if (filters.brand != null) count++;
  if (filters.model != null) count++;
  if (filters.minPrice != null || filters.maxPrice != null) count++;
  if (filters.minYear != null || filters.maxYear != null) count++;
  if (filters.maxMileage != null) count++;
  if (filters.condition != null) count++;
  if (filters.transmissionType != null) count++;
  if (filters.fuelType != null) count++;

  return count;
});
