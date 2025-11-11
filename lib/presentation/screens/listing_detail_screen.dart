import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/listing_providers.dart';
import '../controllers/listing_state.dart';
import '../../core/utils/formatters.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(listingDetailControllerProvider.notifier)
          .loadListing(widget.listingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingDetailControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Toggle favorite
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share listing
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ListingDetailState state) {
    if (state.status == ListingStateStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ListingStateStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[300],
              ),
              const SizedBox(height: 24),
              Text(
                'Unable to Load Listing',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'This listing may have been removed or is temporarily unavailable.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(listingDetailControllerProvider.notifier)
                          .loadListing(widget.listingId);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final listing = state.listing;
    if (listing == null) {
      return const Center(child: Text('Listing not found'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(listing.imageUrls),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (listing.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PREMIUM LISTING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${listing.brand} ${listing.model}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.formatPrice(listing.price),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSpecifications(listing),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(listing.description),
                const SizedBox(height: 16),
                Text(
                  'Views: ${listing.viewCount}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.car_rental, size: 64),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: imageUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              );
            },
          ),
        ),
        if (imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSpecifications(listing) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSpecRow('Year', listing.year.toString()),
            if (listing.condition != null)
              _buildSpecRow('Condition', _getConditionText(listing.condition)),
            _buildSpecRow('Mileage', Formatters.formatMileage(listing.mileage)),
            if (listing.bodyType != null)
              _buildSpecRow('Body Type', _getBodyTypeText(listing.bodyType)),
            if (listing.transmissionType != null)
              _buildSpecRow('Transmission', _getTransmissionText(listing.transmissionType)),
            if (listing.fuelType != null)
              _buildSpecRow('Fuel Type', _getFuelTypeText(listing.fuelType)),
            if (listing.location != null)
              _buildSpecRow('Location', listing.location!),
            ...listing.specifications.entries.map(
              (entry) => _buildSpecRow(
                entry.key,
                entry.value.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBodyTypeText(bodyType) {
    switch (bodyType.toString().split('.').last) {
      case 'sedan': return 'Sedan';
      case 'coupe': return 'Coupe';
      case 'suv': return 'SUV';
      case 'hatchback': return 'Hatchback';
      case 'convertible': return 'Convertible';
      case 'pickup': return 'Pickup';
      case 'van': return 'Van';
      case 'wagon': return 'Wagon';
      default: return 'Other';
    }
  }

  String _getConditionText(condition) {
    switch (condition.toString().split('.').last) {
      case 'brandNew': return 'Brand New';
      case 'used': return 'Used';
      case 'certifiedPreOwned': return 'Certified Pre-Owned';
      default: return 'Used';
    }
  }

  String _getTransmissionText(transmission) {
    switch (transmission.toString().split('.').last) {
      case 'automatic': return 'Automatic';
      case 'manual': return 'Manual';
      case 'cvt': return 'CVT';
      case 'dct': return 'DCT';
      default: return 'Manual';
    }
  }

  String _getFuelTypeText(fuel) {
    switch (fuel.toString().split('.').last) {
      case 'petrol': return 'Petrol';
      case 'diesel': return 'Diesel';
      case 'electric': return 'Electric';
      case 'hybrid': return 'Hybrid';
      case 'pluginHybrid': return 'Plug-in Hybrid';
      case 'lpg': return 'LPG';
      default: return 'Petrol';
    }
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
