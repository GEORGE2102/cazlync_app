import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/listing_entity.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserEntity? user;
  final List<ListingEntity> userListings;
  final Map<String, int> stats;
  final String? errorMessage;
  final bool isUpdating;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.userListings = const [],
    this.stats = const {},
    this.errorMessage,
    this.isUpdating = false,
  });

  @override
  List<Object?> get props => [
        status,
        user,
        userListings,
        stats,
        errorMessage,
        isUpdating,
      ];

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    List<ListingEntity>? userListings,
    Map<String, int>? stats,
    String? errorMessage,
    bool? isUpdating,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      userListings: userListings ?? this.userListings,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}
