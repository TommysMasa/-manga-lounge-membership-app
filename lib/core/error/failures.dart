import 'package:equatable/equatable.dart';

/// Base class for all failures
/// Failures represent errors in the domain/business logic layer
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Database operation failed']);
}

// Authentication failures
class InvalidPhoneNumberFailure extends Failure {
  const InvalidPhoneNumberFailure([
    super.message = 'Invalid phone number format',
  ]);
}

class InvalidOTPFailure extends Failure {
  const InvalidOTPFailure([super.message = 'Invalid OTP code']);
}

class OTPExpiredFailure extends Failure {
  const OTPExpiredFailure([super.message = 'OTP code has expired']);
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure([
    super.message = 'Too many requests. Please try again later',
  ]);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication failed']);
}

class ReauthenticationRequiredFailure extends Failure {
  const ReauthenticationRequiredFailure([
    super.message = 'Reauthentication required for this operation',
  ]);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([super.message = 'User not found']);
}

// User profile failures
class ProfileNotFoundFailure extends Failure {
  const ProfileNotFoundFailure([super.message = 'User profile not found']);
}

class ProfileCreationFailure extends Failure {
  const ProfileCreationFailure([
    super.message = 'Failed to create user profile',
  ]);
}

class ProfileUpdateFailure extends Failure {
  const ProfileUpdateFailure([super.message = 'Failed to update user profile']);
}

class InvalidAgeFailure extends Failure {
  const InvalidAgeFailure([
    super.message = 'User must be at least 13 years old',
  ]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}
