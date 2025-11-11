import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/search_providers.dart';
import '../controllers/listing_state.dart';
import '../widgets/listing_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'listing_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    final activeFiltersCount = ref.watch(activeFiltersCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search cars...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          style: const TextStyle(fontSize: 18),
          onChanged: (value) {
            ref.read(searchControllerProvider.notifier).search(value);
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchControllerProvider.notifier).clearSearch();
              },
            ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
              if (activeFiltersCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$activeFiltersCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters chips
          if (activeFiltersCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._buildFilterChips(),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () {
                              ref
                                  .read(searchControllerProvider.notifier)
                                  .clearFilters();
                            },
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('Clear All'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          
          // Search results
          Expanded(
            child: _buildSearchResults(searchState),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    final filters = ref.watch(searchControllerProvider).filters;
    final chips = <Widget>[];

    if (filters.brand != null) {
      chips.add(_buildChip('Brand: ${filters.brand}', () {
        ref.read(searchControllerProvider.notifier).updateBrand(null);
      }));
    }

    if (filters.model != null) {
      chips.add(_buildChip('Model: ${filters.model}', () {
        ref.read(searchControllerProvider.notifier).updateModel(null);
      }));
    }

    if (filters.minPrice != null || filters.maxPrice != null) {
      final priceText = filters.minPrice != null && filters.maxPrice != null
          ? 'K${filters.minPrice} - K${filters.maxPrice}'
          : filters.minPrice != null
              ? 'From K${filters.minPrice}'
              : 'Up to K${filters.maxPrice}';
      chips.add(_buildChip('Price: $priceText', () {
        ref.read(searchControllerProvider.notifier).updatePriceRange(null, null);
      }));
    }

    if (filters.minYear != null || filters.maxYear != null) {
      final yearText = filters.minYear != null && filters.maxYear != null
          ? '${filters.minYear} - ${filters.maxYear}'
          : filters.minYear != null
              ? 'From ${filters.minYear}'
              : 'Up to ${filters.maxYear}';
      chips.add(_buildChip('Year: $yearText', () {
        ref.read(searchControllerProvider.notifier).updateYearRange(null, null);
      }));
    }

    if (filters.maxMileage != null) {
      chips.add(_buildChip('Mileage: Up to ${filters.maxMileage} km', () {
        ref.read(searchControllerProvider.notifier).updateMaxMileage(null);
      }));
    }

    if (filters.condition != null) {
      chips.add(_buildChip('Condition: ${filters.condition}', () {
        ref.read(searchControllerProvider.notifier).updateCondition(null);
      }));
    }

    if (filters.transmission != null) {
      chips.add(_buildChip('Transmission: ${filters.transmission}', () {
        ref.read(searchControllerProvider.notifier).updateTransmission(null);
      }));
    }

    if (filters.fuelType != null) {
      chips.add(_buildChip('Fuel: ${filters.fuelType}', () {
        ref.read(searchControllerProvider.notifier).updateFuelType(null);
      }));
    }

    return chips;
  }

  Widget _buildChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onDelete,
        deleteIcon: const Icon(Icons.close, size: 18),
        labelStyle: const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildSearchResults(searchState) {
    if (searchState.status == ListingStateStatus.loading &&
        searchState.listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.status == ListingStateStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading results',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                searchState.errorMessage ?? 'Please try again',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(searchControllerProvider.notifier).retry();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (searchState.listings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                'No Results Found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Try adjusting your search or filters',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: searchState.listings.length,
      itemBuilder: (context, index) {
        final listing = searchState.listings[index];
        return ListingCard(
          listing: listing,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListingDetailScreen(
                  listingId: listing.id,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
