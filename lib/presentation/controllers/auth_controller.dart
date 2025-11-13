import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/services/notification_service.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AuthState()) {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authRepository.authStateChanges().listen((user) {
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearError: true,
        );
      }
    });
  }

  // Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _authRepository.signInWithEmail(email, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (user) async {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          clearError: true,
        );
        
        // Store FCM token after successful login
        await _storeFCMToken(user.id);
      },
    );
  }
  
  // Store FCM token for push notifications
  Future<void> _storeFCMToken(String userId) async {
    try {
      final notificationService = NotificationService();
      await notificationService.storeFCMToken(userId);
    } catch (e) {
      // Silently fail - notifications are not critical
      print('Failed to store FCM token: $e');
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _authRepository.signUpWithEmail(
      email,
      password,
      displayName,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (user) async {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          clearError: true,
        );
        
        // Store FCM token after successful sign up
        await _storeFCMToken(user.id);
      },
    );
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _authRepository.signInWithGoogle();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  // Sign in with Facebook
  Future<void> signInWithFacebook() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _authRepository.signInWithFacebook();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  // Sign in with phone
  Future<String?> signInWithPhone(String phoneNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _authRepository.signInWithPhone(phoneNumber);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return null;
      },
      (verificationId) {
        state = state.copyWith(isLoading: false, clearError: true);
        return verificationId;
      },
    );
  }

  // Verify phone OTP
  Future<void> verifyPhoneOTP(String verificationId, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _authRepository.verifyPhoneOTP(verificationId, otp);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _authRepository.signOut();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }

  // Refresh current user data
  Future<void> refreshUser() async {
    state = state.copyWith(isLoading: true);
    
    final result = await _authRepository.getCurrentUser();
    
    result.fold(
      (failure) {
        // Silently fail - user is still authenticated
        state = state.copyWith(isLoading: false);
      },
      (user) {
        if (user != null) {
          state = state.copyWith(user: user, isLoading: false);
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
    );
  }

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
