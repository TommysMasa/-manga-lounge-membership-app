import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';

/// Abstract Authentication Data Source
///
/// Defines the contract for authentication data operations.
/// This abstraction allows us to:
/// - Mock Firebase for testing
/// - Swap Firebase for another provider if needed
/// - Keep domain layer independent of Firebase
abstract class AuthDataSource {
  /// Send OTP to phone number
  /// Returns verification ID needed for OTP verification
  /// Throws [AuthException] on failure
  Future<String> sendOTP(String phoneNumber);

  /// Verify OTP code
  /// Returns authenticated user ID
  /// Throws [AuthException] on failure
  Future<String> verifyOTP({
    required String verificationId,
    required String otpCode,
  });

  /// Sign out current user
  /// Throws [AuthException] on failure
  Future<void> signOut();

  /// Stream of auth state changes
  /// Emits user ID when authenticated, null when not
  /// Throws [AuthException] on error
  Stream<String?> authStateChanges();

  /// Get current authenticated user ID
  /// Returns null if not authenticated
  Future<String?> getCurrentUserId();
}

/// Firebase Implementation of AuthDataSource
///
/// This is the concrete implementation that talks to Firebase Auth.
/// All Firebase-specific code is contained here.
class FirebaseAuthDataSource implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<String> sendOTP(String phoneNumber) async {
    try {
      String? verificationId;
      Exception? error;

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          // We don't handle this here as it's an edge case
        },
        verificationFailed: (FirebaseAuthException e) {
          error = e;
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        timeout: const Duration(seconds: 60),
      );

      if (error != null) {
        final firebaseError = error as FirebaseAuthException;
        throw AuthException(
          _getErrorMessage(firebaseError.code),
          firebaseError.code,
        );
      }

      if (verificationId == null) {
        throw const AuthException('Failed to send OTP. Please try again.');
      }

      return verificationId!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<String> verifyOTP({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw const AuthException('Authentication failed. Please try again.');
      }

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Stream<String?> authStateChanges() {
    try {
      return _firebaseAuth.authStateChanges().map((user) => user?.uid);
    } catch (e) {
      throw AuthException('Error monitoring auth state: ${e.toString()}');
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    try {
      return _firebaseAuth.currentUser?.uid;
    } catch (e) {
      throw AuthException('Error getting current user: ${e.toString()}');
    }
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again.';
      case 'session-expired':
        return 'OTP code has expired. Please request a new one.';
      case 'quota-exceeded':
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
