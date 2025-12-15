import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

/// Authentication Repository Interface
///
/// This defines the contract for authentication operations.
/// The actual implementation will be in the data layer (AuthRepositoryImpl).
///
/// Following the Dependency Inversion Principle:
/// - Domain layer (this interface) doesn't depend on data layer
/// - Data layer (implementation) depends on domain layer (this interface)
///
/// All methods return Either<Failure, T>:
/// - Left(Failure): Operation failed
/// - Right(T): Operation succeeded with result T
abstract class AuthRepository {
  /// Send OTP verification code to the provided phone number
  ///
  /// Returns:
  /// - Right(verificationId): OTP sent successfully
  /// - Left(Failure): Failed to send OTP
  Future<Either<Failure, String>> sendOTP(String phoneNumber);

  /// Verify the OTP code entered by user
  ///
  /// Parameters:
  /// - [verificationId]: ID received from sendOTP
  /// - [otpCode]: 6-digit code entered by user
  ///
  /// Returns:
  /// - Right(uid): OTP verified, returns authenticated user ID
  /// - Left(Failure): OTP verification failed
  Future<Either<Failure, String>> verifyOTP({
    required String verificationId,
    required String otpCode,
  });

  /// Sign out the current user
  ///
  /// Returns:
  /// - Right(unit): Sign out successful
  /// - Left(Failure): Sign out failed
  Future<Either<Failure, Unit>> signOut();

  /// Stream of authentication state changes
  ///
  /// Emits:
  /// - Right(uid): User is authenticated with given uid
  /// - Right(null): User is not authenticated
  /// - Left(Failure): Error occurred while monitoring auth state
  Stream<Either<Failure, String?>> authStateChanges();

  /// Get current authenticated user ID if any
  ///
  /// Returns:
  /// - Right(uid): User is authenticated
  /// - Right(null): No user is authenticated
  /// - Left(Failure): Error getting current user
  Future<Either<Failure, String?>> getCurrentUserId();
}
