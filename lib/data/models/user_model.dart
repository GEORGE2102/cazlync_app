import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.phoneNumber,
    required super.displayName,
    super.photoUrl,
    super.isVerified,
    super.verificationExpiresAt,
    super.favoriteListings,
    required super.createdAt,
    super.isAdmin,
  });

  // Convert from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      isVerified: data['isVerified'] ?? false,
      verificationExpiresAt: data['verificationExpiresAt'] != null
          ? (data['verificationExpiresAt'] as Timestamp).toDate()
          : null,
      favoriteListings: List<String>.from(data['favoriteListings'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  // Convert from Firebase Auth User
  factory UserModel.fromFirebaseUser(
    String uid,
    String email,
    String displayName, {
    String? phoneNumber,
    String? photoUrl,
  }) {
    return UserModel(
      id: uid,
      email: email,
      phoneNumber: phoneNumber,
      displayName: displayName,
      photoUrl: photoUrl,
      isVerified: false,
      favoriteListings: const [],
      createdAt: DateTime.now(),
      isAdmin: false,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isVerified': isVerified,
      'verificationExpiresAt': verificationExpiresAt != null
          ? Timestamp.fromDate(verificationExpiresAt!)
          : null,
      'favoriteListings': favoriteListings,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAdmin': isAdmin,
    };
  }

  // Convert from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      isVerified: entity.isVerified,
      verificationExpiresAt: entity.verificationExpiresAt,
      favoriteListings: entity.favoriteListings,
      createdAt: entity.createdAt,
      isAdmin: entity.isAdmin,
    );
  }

  // Convert to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      phoneNumber: phoneNumber,
      displayName: displayName,
      photoUrl: photoUrl,
      isVerified: isVerified,
      verificationExpiresAt: verificationExpiresAt,
      favoriteListings: favoriteListings,
      createdAt: createdAt,
      isAdmin: isAdmin,
    );
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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
