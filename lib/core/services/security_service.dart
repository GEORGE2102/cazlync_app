import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityService {
  final FirebaseCrashlytics _crashlytics;
  final FirebaseAnalytics _analytics;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SecurityService({
    FirebaseCrashlytics? crashlytics,
    FirebaseAnalytics? analytics,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Initialize security monitoring
  Future<void> initialize() async {
    // Enable Crashlytics collection
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
    
    // Set user identifier for crash reports
    final user = _auth.currentUser;
    if (user != null) {
      await _crashlytics.setUserIdentifier(user.uid);
    }
  }

  // Log security event
  Future<void> logSecurityEvent({
    required String eventName,
    required String description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Log to Analytics
      await _analytics.logEvent(
        name: 'security_$eventName',
        parameters: {
          'description': description,
          'timestamp': DateTime.now().toIso8601String(),
          ...?additionalData,
        },
      );

      // Log to Firestore for admin review
      await _firestore.collection('securityLogs').add({
        'eventName': eventName,
        'description': description,
        'userId': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'additionalData': additionalData,
      });
    } catch (e) {
      print('Error logging security event: $e');
    }
  }

  // Log failed login attempt
  Future<void> logFailedLogin(String email) async {
    await logSecurityEvent(
      eventName: 'failed_login',
      description: 'Failed login attempt',
      additionalData: {'email': email},
    );
  }

  // Log suspicious activity
  Future<void> logSuspiciousActivity({
    required String activityType,
    required String description,
  }) async {
    await logSecurityEvent(
      eventName: 'suspicious_activity',
      description: description,
      additionalData: {'activityType': activityType},
    );
  }

  // Log data access
  Future<void> logDataAccess({
    required String resourceType,
    required String resourceId,
    required String action,
  }) async {
    await logSecurityEvent(
      eventName: 'data_access',
      description: '$action on $resourceType',
      additionalData: {
        'resourceType': resourceType,
        'resourceId': resourceId,
        'action': action,
      },
    );
  }

  // Log permission denied
  Future<void> logPermissionDenied({
    required String resource,
    required String attemptedAction,
  }) async {
    await logSecurityEvent(
      eventName: 'permission_denied',
      description: 'Permission denied for $attemptedAction on $resource',
      additionalData: {
        'resource': resource,
        'attemptedAction': attemptedAction,
      },
    );
  }

  // Check if user is suspended
  Future<bool> isUserSuspended(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['isSuspended'] == true;
    } catch (e) {
      print('Error checking suspension status: $e');
      return false;
    }
  }

  // Rate limiting check (simple implementation)
  final Map<String, List<DateTime>> _rateLimitMap = {};

  bool checkRateLimit({
    required String userId,
    required String action,
    int maxAttempts = 10,
    Duration window = const Duration(minutes: 1),
  }) {
    final key = '${userId}_$action';
    final now = DateTime.now();
    
    // Get or create attempt list
    _rateLimitMap[key] ??= [];
    
    // Remove old attempts outside the window
    _rateLimitMap[key]!.removeWhere(
      (time) => now.difference(time) > window,
    );
    
    // Check if limit exceeded
    if (_rateLimitMap[key]!.length >= maxAttempts) {
      logSecurityEvent(
        eventName: 'rate_limit_exceeded',
        description: 'Rate limit exceeded for $action',
        additionalData: {
          'action': action,
          'attempts': _rateLimitMap[key]!.length,
        },
      );
      return false;
    }
    
    // Add current attempt
    _rateLimitMap[key]!.add(now);
    return true;
  }

  // Validate session
  Future<bool> validateSession() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if user is suspended
      if (await isUserSuspended(user.uid)) {
        await _auth.signOut();
        return false;
      }

      // Check token expiration
      final idTokenResult = await user.getIdTokenResult();
      final expirationTime = idTokenResult.expirationTime;
      
      if (expirationTime != null && 
          DateTime.now().isAfter(expirationTime)) {
        await _auth.signOut();
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating session: $e');
      return false;
    }
  }

  // Log error with context
  Future<void> logError({
    required dynamic error,
    required StackTrace stackTrace,
    String? context,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      // Log to Crashlytics
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: context,
        information: additionalInfo?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
      );

      // Log to Analytics
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': error.runtimeType.toString(),
          'context': context ?? 'unknown',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Error logging error: $e');
    }
  }

  // Check for SQL injection patterns
  bool containsSQLInjection(String input) {
    final sqlPatterns = [
      RegExp(r"(\bOR\b|\bAND\b).*=.*", caseSensitive: false),
      RegExp(r"';.*--", caseSensitive: false),
      RegExp(r"\bDROP\b.*\bTABLE\b", caseSensitive: false),
      RegExp(r"\bINSERT\b.*\bINTO\b", caseSensitive: false),
      RegExp(r"\bDELETE\b.*\bFROM\b", caseSensitive: false),
      RegExp(r"\bUPDATE\b.*\bSET\b", caseSensitive: false),
    ];

    for (final pattern in sqlPatterns) {
      if (pattern.hasMatch(input)) {
        logSuspiciousActivity(
          activityType: 'sql_injection_attempt',
          description: 'Potential SQL injection detected',
        );
        return true;
      }
    }

    return false;
  }

  // Check for XSS patterns
  bool containsXSS(String input) {
    final xssPatterns = [
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'<iframe', caseSensitive: false),
    ];

    for (final pattern in xssPatterns) {
      if (pattern.hasMatch(input)) {
        logSuspiciousActivity(
          activityType: 'xss_attempt',
          description: 'Potential XSS attack detected',
        );
        return true;
      }
    }

    return false;
  }

  // Sanitize and validate input
  String sanitizeInput(String input) {
    // Remove potential XSS
    String sanitized = input
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');

    // Trim whitespace
    sanitized = sanitized.trim();

    return sanitized;
  }
}
