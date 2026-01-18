import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';

/// Authentication Repository Interface
///
/// This defines the contract for authentication operations.
/// The actual implementation will be in the data layer (AuthRepositoryImpl).
///
/// Following the Dependency Inversion Principle:
/// - Domain layer (this interface) doesn't depend on data layer
/// - Data layer (implementation) depends on domain layer (this interface)
///
/// All methods return `Result<T>`:
/// - Failure (Left): Operation failed
/// - Success (Right): Operation succeeded with result T
abstract class AuthRepository {
  /// Send OTP verification code to the provided phone number
  ///
  /// Returns:
  /// - Success: verificationId - OTP sent successfully
  /// - Failure: Failed to send OTP
  AsyncResult<String> sendOTP(String phoneNumber);

  /// Verify the OTP code entered by user
  ///
  /// Parameters:
  /// - [verificationId]: ID received from sendOTP
  /// - [otpCode]: 6-digit code entered by user
  ///
  /// Returns:
  /// - Success: uid - OTP verified, returns authenticated user ID
  /// - Failure: OTP verification failed
  AsyncResult<String> verifyOTP({
    required String verificationId,
    required String otpCode,
  });

  /// Sign out the current user
  ///
  /// Returns:
  /// - Success: unit - Sign out successful
  /// - Failure: Sign out failed
  AsyncResult<Unit> signOut();

  /// Stream of authentication state changes
  ///
  /// Emits:
  /// - Success: uid - User is authenticated with given uid
  /// - Success: null - User is not authenticated
  /// - Failure: Error occurred while monitoring auth state
  StreamResult<String?> authStateChanges();

  /// Get current authenticated user ID if any
  ///
  /// Returns:
  /// - Success: uid - User is authenticated
  /// - Success: null - No user is authenticated
  /// - Failure: Error getting current user
  AsyncResult<String?> getCurrentUserId();

  /// Get current authenticated user email if any
  ///
  /// Returns:
  /// - Success: email - User is authenticated and has email
  /// - Success: null - No user is authenticated or no email
  String? getCurrentUserEmail();

  /// Get current authenticated user phone number if any
  ///
  /// Returns:
  /// - Success: phoneNumber - User is authenticated and has phone number
  /// - Success: null - No user is authenticated or no phone number
  String? getCurrentUserPhoneNumber();

  /// Update phone number for authenticated user
  ///
  /// This requires the user to verify the new phone number via SMS.
  /// The process:
  /// 1. Send OTP to new phone number
  /// 2. Verify OTP
  /// 3. Update Firebase Auth with new phone credential
  ///
  /// Parameters:
  /// - [verificationId]: ID received from sendOTP for new phone number
  /// - [otpCode]: 6-digit code sent to new phone number
  ///
  /// Returns:
  /// - Success: unit - Phone number updated successfully
  /// - Failure: Failed to update phone number
  AsyncResult<Unit> updatePhoneNumber({
    required String verificationId,
    required String otpCode,
  });

  /// Update email for authenticated user
  ///
  /// This updates the email address for the currently authenticated user.
  /// Note: This only updates Firebase Auth, not Firestore.
  /// The caller is responsible for updating Firestore separately.
  ///
  /// Parameters:
  /// - [newEmail]: New email address to set
  ///
  /// Returns:
  /// - Success: unit - Email updated successfully
  /// - Failure: Failed to update email
  AsyncResult<Unit> updateEmail({
    required String newEmail,
  });

  /// Reload current user data from Firebase Auth
  ///
  /// This refreshes the cached user information (email, phone, etc.)
  /// in the Firebase Auth SDK. Useful after external changes like
  /// email verification.
  ///
  /// Returns:
  /// - Success: unit - User data reloaded successfully
  /// - Failure: Failed to reload user data
  AsyncResult<Unit> reloadCurrentUser();

  /// Reauthenticate user with phone number credential
  ///
  /// This is required for sensitive operations like changing email address.
  /// Firebase Auth requires recent authentication (within ~5 minutes) for
  /// certain operations for security reasons.
  ///
  /// Parameters:
  /// - [verificationId]: ID received from sendOTP
  /// - [otpCode]: 6-digit code sent to user's phone
  ///
  /// Returns:
  /// - Success: unit - Reauthentication successful
  /// - Failure: Reauthentication failed
  AsyncResult<Unit> reauthenticateWithPhoneNumber({
    required String verificationId,
    required String otpCode,
  });

  /// Send sign-in link to email
  ///
  /// This sends a magic link to the user's email for passwordless authentication.
  /// Used for account recovery when user loses access to phone number.
  ///
  /// Parameters:
  /// - [email]: Email address to send the sign-in link to
  /// - [continueUrl]: URL to redirect to after clicking the link
  ///
  /// Returns:
  /// - Success: unit - Email sent successfully
  /// - Failure: Failed to send email
  AsyncResult<Unit> sendSignInLinkToEmail({
    required String email,
    required String continueUrl,
  });
}
