import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../../data/services/listing_service.dart';
import '../../data/services/image_upload_service.dart';
import '../../domain/repositories/listing_repository.dart';
import 'listing_controller.dart';
import 'listing_state.dart';

// Services
final listingServiceProvider = Provider<ListingService>((ref) {
  return ListingService();
});

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});

// Repository
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepositoryImpl(
    listingService: ref.watch(listingServiceProvider),
    imageUploadService: ref.watch(imageUploadServiceProvider),
  );
});

// Controllers
final listingControllerProvider =
    StateNotifierProvider<ListingController, ListingState>((ref) {
  return ListingController(ref.watch(listingRepositoryProvider));
});

final listingDetailControllerProvider =
    StateNotifierProvider<ListingDetailController, ListingDetailState>((ref) {
  return ListingDetailController(ref.watch(listingRepositoryProvider));
});

final createListingControllerProvider =
    StateNotifierProvider<CreateListingController, CreateListingState>((ref) {
  return CreateListingController(ref.watch(listingRepositoryProvider));
});
