import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? phoneNumber;
  final String displayName;
  final String? photoUrl;
  final bool isVerified;
  final DateTime? verificationExpiresAt;
  final List<String> favoriteListings;
  final DateTime createdAt;
  final bool isAdmin;

  const UserEntity({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.displayName,
    this.photoUrl,
    this.isVerified = false,
    this.verificationExpiresAt,
    this.favoriteListings = const [],
    required this.createdAt,
    this.isAdmin = false,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        phoneNumber,
        displayName,
        photoUrl,
        isVerified,
        verificationExpiresAt,
        favoriteListings,
        createdAt,
        isAdmin,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    bool? isVerified,
    DateTime? verificationExpiresAt,
    List<String>? favoriteListings,
    DateTime? createdAt,
    bool? isAdmin,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      verificationExpiresAt: verificationExpiresAt ?? this.verificationExpiresAt,
      favoriteListings: favoriteListings ?? this.favoriteListings,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
