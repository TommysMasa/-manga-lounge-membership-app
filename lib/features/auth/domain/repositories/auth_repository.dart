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
}
