/// Base class for all exceptions
/// Exceptions are thrown at the data layer and converted to Failures
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Thrown when server communication fails
class ServerException extends AppException {
  const ServerException([String message = 'Server error occurred', String? code]) : super(message, code);
}

/// Thrown when cache operations fail
class CacheException extends AppException {
  const CacheException([String message = 'Cache error occurred', String? code]) : super(message, code);
}

/// Thrown when network connection fails
class NetworkException extends AppException {
  const NetworkException([String message = 'Network connection failed', String? code]) : super(message, code);
}

/// Thrown when authentication fails
class AuthException extends AppException {
  const AuthException([String message = 'Authentication failed', String? code]) : super(message, code);
}

/// Thrown when validation fails
class ValidationException extends AppException {
  const ValidationException([String message = 'Validation failed', String? code]) : super(message, code);
}

/// Thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found', String? code]) : super(message, code);
}
