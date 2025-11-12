import 'package:equatable/equatable.dart';
import '../../domain/entities/listing_entity.dart';

enum AdminStatus { initial, loading, success, error }

class AdminState extends Equatable {
  final AdminStatus status;
  final List<ListingEntity> pendingListings;
  final List<ListingEntity> reportedListings;
  final Map<String, dynamic>? analytics;
  final Map<String, dynamic>? userStats;
  final Map<String, dynamic>? listingStats;
  final Map<String, dynamic>? chatStats;
  final String? errorMessage;

  const AdminState({
    this.status = AdminStatus.initial,
    this.pendingListings = const [],
    this.reportedListings = const [],
    this.analytics,
    this.userStats,
    this.listingStats,
    this.chatStats,
    this.errorMessage,
  });

  AdminState copyWith({
    AdminStatus? status,
    List<ListingEntity>? pendingListings,
    List<ListingEntity>? reportedListings,
    Map<String, dynamic>? analytics,
    Map<String, dynamic>? userStats,
    Map<String, dynamic>? listingStats,
    Map<String, dynamic>? chatStats,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      pendingListings: pendingListings ?? this.pendingListings,
      reportedListings: reportedListings ?? this.reportedListings,
      analytics: analytics ?? this.analytics,
      userStats: userStats ?? this.userStats,
      listingStats: listingStats ?? this.listingStats,
      chatStats: chatStats ?? this.chatStats,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pendingListings,
        reportedListings,
        analytics,
        userStats,
        listingStats,
        chatStats,
        errorMessage,
      ];
}
