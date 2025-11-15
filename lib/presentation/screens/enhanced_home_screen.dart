import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/listing_providers.dart';
import '../controllers/listing_state.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'create_listing_screen.dart';
import 'search_screen.dart';
import '../../domain/entities/listing_entity.dart';
import '../../core/utils/formatters.dart';

class EnhancedHomeScreen extends ConsumerStatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  ConsumerState<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends ConsumerState<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _carouselController = ScrollController();
  String _selectedCondition = 'All';
  String? _selectedBrand;
  BodyType? _selectedBodyType;
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(listingControllerProvider.notifier).loadListings();
    });

    _scrollController.addListener(_onScroll);
    
    // Start carousel after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCarouselTimer();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _carouselController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(listingControllerProvider.notifier).loadMore();
    }
  }

  List<ListingEntity> _getFilteredListings(List<ListingEntity> listings) {
    return listings.where((listing) {
      // Show active and sold listings (but not pending, rejected, or deleted)
      if (listing.status != ListingStatus.active && listing.status != ListingStatus.sold) {
        return false;
      }
      
      // Filter by condition
      if (_selectedCondition == 'New' && listing.condition != VehicleCondition.brandNew) {
        return false;
      }
      if (_selectedCondition == 'Used' && listing.condition == VehicleCondition.brandNew) {
        return false;
      }

      // Filter by brand
      if (_selectedBrand != null && listing.brand.toLowerCase() != _selectedBrand!.toLowerCase()) {
        return false;
      }

      // Filter by body type
      if (_selectedBodyType != null && listing.bodyType != _selectedBodyType) {
        return false;
      }

      return true;
    }).toList();
  }

  Map<String, int> _getBrandCounts(List<ListingEntity> listings) {
    final counts = <String, int>{};
    for (final listing in listings) {
      counts[listing.brand] = (counts[listing.brand] ?? 0) + 1;
    }
    return counts;
  }

  Map<BodyType, int> _getBodyTypeCounts(List<ListingEntity> listings) {
    final counts = <BodyType, int>{};
    for (final listing in listings) {
      if (listing.bodyType != null) {
        counts[listing.bodyType!] = (counts[listing.bodyType!] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CazLync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateListingScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ListingState state) {
    if (state.status == ListingStateStatus.loading && state.listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ListingStateStatus.error && state.listings.isEmpty) {
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
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'Unable to load listings',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(listingControllerProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.listings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 120,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'No Cars Available',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Be the first to list a car for sale!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredListings = _getFilteredListings(state.listings);
    final brandCounts = _getBrandCounts(state.listings);
    final bodyTypeCounts = _getBodyTypeCounts(state.listings);
    final topBrands = brandCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(listingControllerProvider.notifier).refresh();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Featured Cars Carousel
          SliverToBoxAdapter(
            child: _buildFeaturedCarsCarousel(filteredListings),
          ),
          
          // Quick Filter Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured listings For You',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Best Deals',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // All/New/Used Toggle
                  Row(
                    children: [
                      _buildConditionChip('All'),
                      const SizedBox(width: 8),
                      _buildConditionChip('New'),
                      const SizedBox(width: 8),
                      _buildConditionChip('Used'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Popular Brands Section
          if (topBrands.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Popular Brands',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: topBrands.take(5).map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildBrandChip(entry.key, entry.value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Body Type Section
          if (bodyTypeCounts.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore body type',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildBodyTypeChip(BodyType.suv, bodyTypeCounts[BodyType.suv] ?? 0),
                          const SizedBox(width: 8),
                          _buildBodyTypeChip(BodyType.sedan, bodyTypeCounts[BodyType.sedan] ?? 0),
                          const SizedBox(width: 8),
                          _buildBodyTypeChip(BodyType.hatchback, bodyTypeCounts[BodyType.hatchback] ?? 0),
                          const SizedBox(width: 8),
                          _buildBodyTypeChip(BodyType.pickup, bodyTypeCounts[BodyType.pickup] ?? 0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Listings Grid
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == filteredListings.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final listing = filteredListings[index];
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
                childCount: filteredListings.length + (state.isLoadingMore ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionChip(String condition) {
    final isSelected = _selectedCondition == condition;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCondition = condition;
          _selectedBrand = null;
          _selectedBodyType = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          condition,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBrandChip(String brand, int count) {
    final isSelected = _selectedBrand == brand;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBrand = isSelected ? null : brand;
          _selectedBodyType = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              brand,
              style: TextStyle(
                color: isSelected ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count Listings',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyTypeChip(BodyType bodyType, int count) {
    final isSelected = _selectedBodyType == bodyType;
    final label = _getBodyTypeLabel(bodyType);
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBodyType = isSelected ? null : bodyType;
          _selectedBrand = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count Listings',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBodyTypeLabel(BodyType type) {
    switch (type) {
      case BodyType.suv:
        return 'SUV / Pickup';
      case BodyType.sedan:
        return 'Sedan';
      case BodyType.hatchback:
        return 'Hatchback';
      case BodyType.pickup:
        return 'Pickup';
      case BodyType.coupe:
        return 'Coupe';
      case BodyType.convertible:
        return 'Convertible';
      case BodyType.van:
        return 'Van';
      case BodyType.wagon:
        return 'Wagon';
      case BodyType.other:
        return 'Other';
    }
  }

  void _startCarouselTimer() {
    // Wait a bit for the controller to be ready
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      _carouselTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        if (_carouselController.hasClients && 
            _carouselController.position.hasContentDimensions) {
          try {
            final maxScroll = _carouselController.position.maxScrollExtent;
            final currentScroll = _carouselController.offset;
            
            // Scroll 3 pixels at a time for visible smooth animation
            final nextScroll = currentScroll + 3.0;
            
            if (nextScroll >= maxScroll - 100) {
              // Jump back to beginning when near the end
              _carouselController.jumpTo(0);
            } else {
              _carouselController.jumpTo(nextScroll);
            }
          } catch (e) {
            // Ignore errors during scroll
            print('Carousel scroll error: $e');
          }
        }
      });
    });
  }

  Widget _buildFeaturedCarsCarousel(List<ListingEntity> listings) {
    if (listings.isEmpty) {
      return const SizedBox.shrink();
    }

    final featuredListings = listings.take(10).toList();

    return Container(
      height: 240,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest Cars',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'New uploads',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Pause auto-scroll when user is manually scrolling
                if (notification is ScrollStartNotification) {
                  _carouselTimer?.cancel();
                } else if (notification is ScrollEndNotification) {
                  // Resume auto-scroll after user stops
                  _startCarouselTimer();
                }
                return false;
              },
              child: ListView.builder(
                controller: _carouselController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: featuredListings.length * 1000,
                itemBuilder: (context, index) {
                  final listing = featuredListings[index % featuredListings.length];
                  return _buildCarouselCard(listing);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselCard(ListingEntity listing) {
    return Container(
      width: 340,
      margin: const EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image with shimmer effect
            Container(
              width: double.infinity,
              height: double.infinity,
              child: CachedNetworkImage(
                imageUrl: listing.imageUrls.isNotEmpty
                    ? listing.imageUrls.first
                    : '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[200]!,
                        Colors.grey[300]!,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[400]!,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car, size: 60, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        'No Image',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Enhanced gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Content with better spacing and design
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand and Model
                    Text(
                      '${listing.brand} ${listing.model}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price with background
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        listing.contactForPrice
                            ? 'Contact for price'
                            : Formatters.formatPrice(listing.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Details row with icons
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.year}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.speed, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatMileage(listing.mileage),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // Condition badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            listing.condition == VehicleCondition.brandNew ? 'NEW' : 'USED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Status badges
            if (listing.status == ListingStatus.sold)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'SOLD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            if (listing.status == ListingStatus.active)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
