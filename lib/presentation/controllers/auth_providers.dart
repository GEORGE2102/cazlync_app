import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

// Service providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.watch(authServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

// Auth controller provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

// Convenience providers
final currentUserProvider = Provider((ref) {
  return ref.watch(authControllerProvider).user;
});

final isAuthenticatedProvider = Provider((ref) {
  return ref.watch(authControllerProvider).isAuthenticated;
});

final isLoadingProvider = Provider((ref) {
  return ref.watch(authControllerProvider).isLoading;
});
