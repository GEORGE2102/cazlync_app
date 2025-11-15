import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/listing_providers.dart';
import '../controllers/listing_state.dart';
import '../controllers/auth_providers.dart';
import '../widgets/listing_card.dart';
import '../../domain/entities/listing_entity.dart';
import '../../data/models/listing_model.dart';
import 'listing_detail_screen.dart';
import 'create_listing_screen.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  List<ListingEntity> _myListings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyListings();
  }

  Future<void> _loadMyListings() async {
    final authState = ref.read(authControllerProvider);
    final currentUserId = authState.user?.id ?? '';
    
    if (currentUserId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please login to view your listings';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Query Firestore directly to get ALL user listings (including sold)
      final snapshot = await FirebaseFirestore.instance
          .collection('listings')
          .where('sellerId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      final listings = snapshot.docs.map((doc) {
        return ListingModel.fromFirestore(doc);
      }).toList();

      setState(() {
        _myListings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateListingScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(_myListings, _isLoading, _errorMessage),
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

  Widget _buildBody(List listings, bool isLoading, String? errorMessage) {
    if (isLoading && listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading listings',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadMyListings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (listings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadMyListings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final listing = listings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMyListingCard(listing),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.car_rental_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Listings Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first listing to start selling your car.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateListingScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Listing'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyListingCard(listing) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Status Indicator Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: _getStatusColor(listing.status),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(listing.status),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(listing.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Listing Content
          InkWell(
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
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: listing.imageUrls.isNotEmpty
                        ? Image.network(
                            listing.imageUrls.first,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 100,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.car_rental),
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${listing.brand} ${listing.model}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'K${listing.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${listing.year} • ${listing.mileage} km',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Action Buttons (only for active listings)
          if (listing.status == ListingStatus.active)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Show "Mark as Active" for sold listings
                  if (listing.status == ListingStatus.sold)
                    TextButton.icon(
                      onPressed: () => _markAsActive(listing.id),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Mark as Active'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  // Show "Mark as Sold" for active listings
                  if (listing.status == ListingStatus.active)
                    TextButton.icon(
                      onPressed: () => _markAsSold(listing.id),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Mark as Sold'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(status) {
    if (status == ListingStatus.active) return Colors.green;
    if (status == ListingStatus.sold) return Colors.red;
    if (status == ListingStatus.pending) return Colors.orange;
    if (status == ListingStatus.rejected) return Colors.red[900]!;
    return Colors.grey;
  }

  IconData _getStatusIcon(status) {
    if (status == ListingStatus.active) return Icons.check_circle;
    if (status == ListingStatus.sold) return Icons.sell;
    if (status == ListingStatus.pending) return Icons.pending;
    if (status == ListingStatus.rejected) return Icons.cancel;
    return Icons.info;
  }

  String _getStatusText(status) {
    if (status == ListingStatus.active) return 'ACTIVE';
    if (status == ListingStatus.sold) return 'SOLD';
    if (status == ListingStatus.pending) return 'PENDING APPROVAL';
    if (status == ListingStatus.rejected) return 'REJECTED';
    if (status == ListingStatus.deleted) return 'DELETED';
    return 'UNKNOWN';
  }

  Future<void> _markAsSold(String listingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Sold'),
        content: const Text(
          'Are you sure you want to mark this listing as sold? It will show with a "SOLD" badge.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Mark as Sold'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Update listing status to sold
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .update({
        'status': 'sold',
        'soldAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing marked as sold'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh listings
        _loadMyListings();
      }
    }
  }

  Future<void> _markAsActive(String listingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Active'),
        content: const Text(
          'Are you sure you want to mark this listing as active again? It will be visible in search results.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Mark as Active'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Update listing status to active
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(listingId)
          .update({
        'status': 'active',
        'soldAt': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing marked as active'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh listings
        _loadMyListings();
      }
    }
  }
}