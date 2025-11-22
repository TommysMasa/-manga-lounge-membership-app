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
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network connection failed']) : super(message);
}

// Authentication failures
class InvalidPhoneNumberFailure extends Failure {
  const InvalidPhoneNumberFailure([String message = 'Invalid phone number format']) : super(message);
}

class InvalidOTPFailure extends Failure {
  const InvalidOTPFailure([String message = 'Invalid OTP code']) : super(message);
}

class OTPExpiredFailure extends Failure {
  const OTPExpiredFailure([String message = 'OTP code has expired']) : super(message);
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure([String message = 'Too many requests. Please try again later']) : super(message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String message = 'Authentication failed']) : super(message);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([String message = 'User not found']) : super(message);
}

// User profile failures
class ProfileNotFoundFailure extends Failure {
  const ProfileNotFoundFailure([String message = 'User profile not found']) : super(message);
}

class ProfileCreationFailure extends Failure {
  const ProfileCreationFailure([String message = 'Failed to create user profile']) : super(message);
}

class ProfileUpdateFailure extends Failure {
  const ProfileUpdateFailure([String message = 'Failed to update user profile']) : super(message);
}

class InvalidAgeFailure extends Failure {
  const InvalidAgeFailure([String message = 'User must be at least 13 years old']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed']) : super(message);
}
