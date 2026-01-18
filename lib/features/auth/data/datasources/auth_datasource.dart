import 'dart:async';

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

  /// Get current authenticated user email
  /// Returns null if not authenticated or no email
  String? getCurrentUserEmail();

  /// Get current authenticated user phone number
  /// Returns null if not authenticated or no phone number
  String? getCurrentUserPhoneNumber();

  /// Update phone number for authenticated user
  /// Throws [AuthException] on failure
  Future<void> updatePhoneNumber({
    required String verificationId,
    required String otpCode,
  });

  /// Update email for authenticated user
  /// Throws [AuthException] on failure
  Future<void> updateEmail({
    required String newEmail,
  });

  /// Reload current user data from Firebase Auth
  /// This refreshes the cached user information (email, phone, etc.)
  /// Throws [AuthException] on failure
  Future<void> reloadCurrentUser();

  /// Send email link for passwordless sign-in
  /// Returns void on success
  /// Throws [AuthException] on failure
  Future<void> sendSignInLinkToEmail({
    required String email,
    required String continueUrl,
  });

  /// Sign in with email link
  /// Returns authenticated user ID
  /// Throws [AuthException] on failure
  Future<String> signInWithEmailLink({
    required String email,
    required String emailLink,
  });

  /// Check if a link is a valid sign-in link
  /// Returns true if valid, false otherwise
  bool isSignInWithEmailLink(String emailLink);

  /// Reauthenticate user with phone number credential
  /// This is required for sensitive operations like changing email address
  /// Throws [AuthException] on failure
  Future<void> reauthenticateWithPhoneNumber({
    required String verificationId,
    required String otpCode,
  });
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
      // Completer bridges callback-based verifyPhoneNumber to async/await
      final completer = Completer<String>();
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          // We don't handle this here as it's an edge case
        },
        verificationFailed: (FirebaseAuthException e) {
          // Complete the completer with error so await throws it
          if (!completer.isCompleted) {
            completer.completeError(
              AuthException(_getErrorMessage(e.code), e.code),
            );
          }
        },
        codeSent: (String verId, int? resendToken) {
          // Complete the completer with verificationId so await returns it
          if (!completer.isCompleted) {
            completer.complete(verId);
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          // Complete with verificationId even on timeout (user can still enter code)
          if (!completer.isCompleted) {
            completer.complete(verId);
          }
        },
        timeout: const Duration(seconds: 30),
      );

      // Wait for one of the callbacks to complete the completer
      return await completer.future;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      // This catches both AuthException from completer.completeError
      // and any other unexpected errors
      if (e is AuthException) rethrow;
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

  @override
  String? getCurrentUserEmail() {
    try {
      return _firebaseAuth.currentUser?.email;
    } catch (e) {
      print('DEBUG getCurrentUserEmail: Error getting current user email: $e');
      return null;
    }
  }

  @override
  String? getCurrentUserPhoneNumber() {
    try {
      return _firebaseAuth.currentUser?.phoneNumber;
    } catch (e) {
      print('DEBUG getCurrentUserPhoneNumber: Error getting current user phone number: $e');
      return null;
    }
  }

  @override
  Future<void> updatePhoneNumber({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No authenticated user found');
      }

      print('DEBUG updatePhoneNumber: Creating credential with verificationId: $verificationId, otpCode: $otpCode');
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      print('DEBUG updatePhoneNumber: Calling user.updatePhoneNumber');
      await user.updatePhoneNumber(credential);
      print('DEBUG updatePhoneNumber: Successfully updated phone number');
    } on FirebaseAuthException catch (e) {
      print('DEBUG updatePhoneNumber: FirebaseAuthException - code: ${e.code}, message: ${e.message}');
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      print('DEBUG updatePhoneNumber: Unexpected error: $e');
      throw AuthException('Failed to update phone number: ${e.toString()}');
    }
  }

  @override
  Future<void> updateEmail({
    required String newEmail,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No authenticated user found');
      }

      print('DEBUG updateEmail: Updating email to $newEmail for user ${user.uid}');
      await user.verifyBeforeUpdateEmail(newEmail);
      print('DEBUG updateEmail: Successfully sent verification email');
    } on FirebaseAuthException catch (e) {
      print('DEBUG updateEmail: FirebaseAuthException - code: ${e.code}, message: ${e.message}');
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      print('DEBUG updateEmail: Unexpected error: $e');
      throw AuthException('Failed to update email: ${e.toString()}');
    }
  }

  @override
  Future<void> reloadCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        // No user to reload - just return without error
        print('DEBUG reloadCurrentUser: No authenticated user found');
        return;
      }

      print('DEBUG reloadCurrentUser: Reloading user data for ${user.uid}');

      try {
        // First, refresh the ID token to ensure it's valid
        // This prevents token-expired errors during reload
        print('DEBUG reloadCurrentUser: Refreshing ID token...');
        await user.getIdToken(true);  // forceRefresh = true

        // Now reload user data from server
        print('DEBUG reloadCurrentUser: Token refreshed, reloading user data...');
        await user.reload();
        print('DEBUG reloadCurrentUser: Successfully reloaded user data');
      } on FirebaseAuthException catch (e) {
        // Don't throw - just log and continue with cached data
        // This prevents forced logout when reload fails
        print('DEBUG reloadCurrentUser: Failed to reload (${e.code}), continuing with cached data');
      }
    } catch (e) {
      // Don't throw - just log and continue with cached data
      print('DEBUG reloadCurrentUser: Failed to reload ($e), continuing with cached data');
    }
  }

  @override
  Future<void> sendSignInLinkToEmail({
    required String email,
    required String continueUrl,
  }) async {
    try {
      print('DEBUG sendSignInLinkToEmail: Sending email link to $email');

      final actionCodeSettings = ActionCodeSettings(
        url: continueUrl,
        handleCodeInApp: true,
        iOSBundleId: 'com.mangalounge.memberapp',
        androidPackageName: 'com.mangalounge.memberapp',
        androidInstallApp: true,
        androidMinimumVersion: '12',
      );

      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      print('DEBUG sendSignInLinkToEmail: Email sent successfully');
    } on FirebaseAuthException catch (e) {
      print('DEBUG sendSignInLinkToEmail: FirebaseAuthException - code: ${e.code}, message: ${e.message}');
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      print('DEBUG sendSignInLinkToEmail: Unexpected error: $e');
      throw AuthException('Failed to send email link: ${e.toString()}');
    }
  }

  @override
  Future<String> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      print('DEBUG signInWithEmailLink: Signing in with email: $email');

      final userCredential = await _firebaseAuth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      if (userCredential.user == null) {
        throw const AuthException('Authentication failed. Please try again.');
      }

      print('DEBUG signInWithEmailLink: Successfully signed in, uid: ${userCredential.user!.uid}');
      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      print('DEBUG signInWithEmailLink: FirebaseAuthException - code: ${e.code}, message: ${e.message}');
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      print('DEBUG signInWithEmailLink: Unexpected error: $e');
      throw AuthException('Failed to sign in with email link: ${e.toString()}');
    }
  }

  @override
  bool isSignInWithEmailLink(String emailLink) {
    try {
      return _firebaseAuth.isSignInWithEmailLink(emailLink);
    } catch (e) {
      print('DEBUG isSignInWithEmailLink: Error checking link: $e');
      return false;
    }
  }

  @override
  Future<void> reauthenticateWithPhoneNumber({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No authenticated user found');
      }

      print('DEBUG reauthenticateWithPhoneNumber: Creating credential for user ${user.uid}');

      // Create phone credential
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      // Reauthenticate user
      print('DEBUG reauthenticateWithPhoneNumber: Reauthenticating user');
      await user.reauthenticateWithCredential(credential);

      print('DEBUG reauthenticateWithPhoneNumber: Successfully reauthenticated');
    } on FirebaseAuthException catch (e) {
      print('DEBUG reauthenticateWithPhoneNumber: FirebaseAuthException - code: ${e.code}, message: ${e.message}');
      throw AuthException(_getErrorMessage(e.code), e.code);
    } catch (e) {
      print('DEBUG reauthenticateWithPhoneNumber: Unexpected error: $e');
      throw AuthException('Failed to reauthenticate: ${e.toString()}');
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
      case 'invalid-email':
        return 'Invalid email address';
      case 'invalid-action-code':
        return 'Invalid or expired link. Please request a new one.';
      case 'expired-action-code':
        return 'Link has expired. Please request a new one.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
