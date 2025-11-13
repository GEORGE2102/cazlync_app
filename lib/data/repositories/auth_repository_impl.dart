import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepositoryImpl({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final firebaseUser = await _authService.signInWithEmail(email, password);
      final user = await _getOrCreateUser(firebaseUser);
      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final firebaseUser = await _authService.signUpWithEmail(
        email,
        password,
        displayName,
      );
      final user = await _createUserInFirestore(firebaseUser, displayName);
      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final firebaseUser = await _authService.signInWithGoogle();
      if (firebaseUser == null) {
        return const Left(AuthenticationFailure('Google sign-in was cancelled'));
      }
      final user = await _getOrCreateUser(firebaseUser);
      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithFacebook() async {
    try {
      final firebaseUser = await _authService.signInWithFacebook();
      if (firebaseUser == null) {
        return const Left(AuthenticationFailure('Facebook sign-in was cancelled'));
      }
      final user = await _getOrCreateUser(firebaseUser);
      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> signInWithPhone(String phoneNumber) async {
    try {
      final verificationId = await _authService.signInWithPhone(phoneNumber);
      return Right(verificationId);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyPhoneOTP(
    String verificationId,
    String otp,
  ) async {
    try {
      final firebaseUser = await _authService.verifyPhoneOTP(verificationId, otp);
      final user = await _getOrCreateUser(firebaseUser);
      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authService.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to sign out: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) {
        return const Right(null);
      }
      final user = await _firestoreService.getUser(firebaseUser.uid);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _authService.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        return await _firestoreService.getUser(firebaseUser.uid);
      } catch (e) {
        return null;
      }
    });
  }

  // Helper method to get existing user or create new one
  Future<UserEntity> _getOrCreateUser(firebase_auth.User firebaseUser) async {
    try {
      // Try to get existing user
      final existingUser = await _firestoreService.getUser(firebaseUser.uid);
      if (existingUser != null) {
        return existingUser;
      }
    } catch (e) {
      // User doesn't exist, create new one
    }

    // Create new user in Firestore
    return await _createUserInFirestore(
      firebaseUser,
      firebaseUser.displayName ?? 'User',
    );
  }

  // Helper method to create user in Firestore
  // IMPORTANT: This uses merge: true to preserve existing fields like isAdmin
  Future<UserEntity> _createUserInFirestore(
    firebase_auth.User firebaseUser,
    String displayName,
  ) async {
    // First, check if user document already exists
    final existingUser = await _firestoreService.getUser(firebaseUser.uid);
    if (existingUser != null) {
      // User document exists, return it (preserves isAdmin and other fields)
      return existingUser;
    }

    // User doesn't exist, create new one
    final userModel = UserModel.fromFirebaseUser(
      firebaseUser.uid,
      firebaseUser.email ?? '',
      displayName,
      phoneNumber: firebaseUser.phoneNumber,
      photoUrl: firebaseUser.photoURL,
    );

    // Create user document
    await _firestoreService.createUser(userModel);
    
    // Return the created user
    return userModel.toEntity();
  }
}
