/// Base class for all exceptions
/// Exceptions are thrown at the data layer and converted to Failures
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Thrown when server communication fails
class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred', super.code]);
}

/// Thrown when cache operations fail
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred', super.code]);
}

/// Thrown when network connection fails
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Network connection failed',
    super.code,
  ]);
}

/// Thrown when authentication fails
class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed', super.code]);
}

/// Thrown when validation fails
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed', super.code]);
}

/// Thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found', super.code]);
}

/// Thrown when Firestore operations fail
class FirestoreException extends AppException {
  const FirestoreException({
    String message = 'Firestore operation failed',
    String? code,
  }) : super(message, code);
}

/// Thrown when user is not found
class UserNotFoundException extends NotFoundException {
  const UserNotFoundException([super.message = 'User not found', super.code]);
}
