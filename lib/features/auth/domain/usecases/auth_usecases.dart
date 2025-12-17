import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Use Cases for Authentication
///
/// Following the YAGNI principle, we group related use cases in one file
/// instead of creating separate files for each use case.
///
/// Each use case has a single responsibility and is easily testable.
/// Use cases contain business logic and orchestrate repository calls.

/// Send OTP verification code to phone number
class SendOTP {
  final AuthRepository repository;

  SendOTP(this.repository);

  /// Send OTP to the provided phone number
  ///
  /// Returns:
  /// - Success: verificationId - OTP sent successfully
  /// - Failure: Failed to send OTP
  AsyncResult<String> call(String phoneNumber) async {
    // Business logic: Validate phone number format before sending
    if (phoneNumber.isEmpty) {
      return Results.failure(
        const InvalidPhoneNumberFailure('Phone number cannot be empty'),
      );
    }

    if (!phoneNumber.startsWith('+')) {
      return Results.failure(
        const InvalidPhoneNumberFailure('Phone number must include country code'),
      );
    }

    return await repository.sendOTP(phoneNumber);
  }
}

/// Verify OTP code entered by user
class VerifyOTP {
  final AuthRepository repository;

  VerifyOTP(this.repository);

  /// Verify the OTP code
  ///
  /// Returns:
  /// - Success: uid - OTP verified successfully, returns user ID
  /// - Failure: OTP verification failed
  AsyncResult<String> call({
    required String verificationId,
    required String otpCode,
  }) async {
    // Business logic: Validate OTP format
    if (verificationId.isEmpty) {
      return Results.failure(
        const ValidationFailure('Verification ID is required'),
      );
    }

    if (otpCode.isEmpty) {
      return Results.failure(const InvalidOTPFailure('OTP code cannot be empty'));
    }

    if (otpCode.length != 6) {
      return Results.failure(const InvalidOTPFailure('OTP code must be 6 digits'));
    }

    return await repository.verifyOTP(
      verificationId: verificationId,
      otpCode: otpCode,
    );
  }
}

/// Sign out the current user
class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  /// Sign out the authenticated user
  ///
  /// Returns:
  /// - Success: unit - Sign out successful
  /// - Failure: Sign out failed
  AsyncResult<Unit> call() async {
    return await repository.signOut();
  }
}

/// Monitor authentication state changes
class WatchAuthState {
  final AuthRepository repository;

  WatchAuthState(this.repository);

  /// Stream of authentication state changes
  ///
  /// Emits:
  /// - Success: uid - User is authenticated
  /// - Success: null - User is not authenticated
  /// - Failure: Error occurred
  StreamResult<String?> call() {
    return repository.authStateChanges();
  }
}

/// Get current authenticated user ID
class GetCurrentUserId {
  final AuthRepository repository;

  GetCurrentUserId(this.repository);

  /// Get the current user's ID if authenticated
  ///
  /// Returns:
  /// - Success: uid - User is authenticated
  /// - Success: null - No authenticated user
  /// - Failure: Error occurred
  AsyncResult<String?> call() async {
    return await repository.getCurrentUserId();
  }
}
