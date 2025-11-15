import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/errors/exceptions.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn;
  final FacebookAuth _facebookAuth;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FacebookAuth? facebookAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        // Don't initialize GoogleSignIn on web without client ID
        _googleSignIn = kIsWeb ? null : (googleSignIn ?? GoogleSignIn()),
        _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Auth state changes stream
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  // Sign in with email and password
  Future<User> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw AuthenticationException('Sign in failed');
      }
      
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthenticationException('An unexpected error occurred');
    }
  }

  // Sign up with email and password
  Future<User> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthenticationException('Sign up failed');
      }

      // Update display name
      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();

      return _firebaseAuth.currentUser!;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthenticationException('An unexpected error occurred');
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available
      if (_googleSignIn == null) {
        throw AuthenticationException(
          'Google Sign-In is not configured for this platform',
        );
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthenticationException('Google sign-in failed');
    }
  }

  // Sign in with Facebook
  Future<User?> signInWithFacebook() async {
    try {
      // Trigger the Facebook authentication flow
      final LoginResult result = await _facebookAuth.login();

      if (result.status == LoginStatus.cancelled) {
        // User cancelled the sign-in
        return null;
      }

      if (result.status != LoginStatus.success) {
        throw AuthenticationException('Facebook sign-in failed');
      }

      // Create a credential from the access token
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      // Sign in to Firebase with the Facebook credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthenticationException('Facebook sign-in failed');
    }
  }

  // Sign in with phone number
  Future<String> signInWithPhone(String phoneNumber) async {
    try {
      String? verificationId;
      
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw AuthenticationException(_getAuthErrorMessage(e.code));
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        timeout: const Duration(seconds: 60),
      );

      // Wait for verification ID
      await Future.delayed(const Duration(seconds: 2));

      if (verificationId == null) {
        throw AuthenticationException('Failed to send verification code');
      }

      return verificationId!;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthenticationException('Phone verification failed');
    }
  }

  // Verify phone OTP
  Future<User> verifyPhoneOTP(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw AuthenticationException('Verification failed');
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthenticationException('OTP verification failed');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthenticationException('Failed to send password reset email');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Firebase first
      await _firebaseAuth.signOut();
      
      // Try to sign out from social providers, but don't fail if they error
      try {
        await _facebookAuth.logOut();
      } catch (e) {
        // Ignore Facebook logout errors
      }
      
      // Only sign out from Google if it's initialized
      if (_googleSignIn != null) {
        try {
          await _googleSignIn!.signOut();
        } catch (e) {
          // Ignore Google logout errors
        }
      }
    } catch (e) {
      // Only throw if Firebase sign out fails
      throw AuthenticationException('Sign out failed');
    }
  }

  // Helper method to get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      case 'session-expired':
        return 'Verification session expired. Please try again';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
