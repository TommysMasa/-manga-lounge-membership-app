import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
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
  /// - Right(verificationId): OTP sent successfully
  /// - Left(Failure): Failed to send OTP
  Future<Either<Failure, String>> call(String phoneNumber) async {
    // Business logic: Validate phone number format before sending
    if (phoneNumber.isEmpty) {
      return const Left(
        InvalidPhoneNumberFailure('Phone number cannot be empty'),
      );
    }

    if (!phoneNumber.startsWith('+')) {
      return const Left(
        InvalidPhoneNumberFailure('Phone number must include country code'),
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
  /// - Right(uid): OTP verified successfully, returns user ID
  /// - Left(Failure): OTP verification failed
  Future<Either<Failure, String>> call({
    required String verificationId,
    required String otpCode,
  }) async {
    // Business logic: Validate OTP format
    if (verificationId.isEmpty) {
      return const Left(
        ValidationFailure('Verification ID is required'),
      );
    }

    if (otpCode.isEmpty) {
      return const Left(InvalidOTPFailure('OTP code cannot be empty'));
    }

    if (otpCode.length != 6) {
      return const Left(InvalidOTPFailure('OTP code must be 6 digits'));
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
  /// - Right(unit): Sign out successful
  /// - Left(Failure): Sign out failed
  Future<Either<Failure, Unit>> call() async {
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
  /// - Right(uid): User is authenticated
  /// - Right(null): User is not authenticated
  /// - Left(Failure): Error occurred
  Stream<Either<Failure, String?>> call() {
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
  /// - Right(uid): User is authenticated
  /// - Right(null): No authenticated user
  /// - Left(Failure): Error occurred
  Future<Either<Failure, String?>> call() async {
    return await repository.getCurrentUserId();
  }
}
