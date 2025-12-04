import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Represents the authentication state of the application
///
/// This entity uses Freezed for immutability and sealed class pattern.
/// Each state represents a specific authentication scenario.
@freezed
class AuthState with _$AuthState {
  /// Initial state when app starts
  const factory AuthState.initial() = _Initial;

  /// User is authenticated
  /// [uid] is the authenticated user's unique identifier
  const factory AuthState.authenticated(String uid) = _Authenticated;

  /// User is not authenticated
  const factory AuthState.unauthenticated() = _Unauthenticated;

  /// OTP has been sent to the phone number
  /// [verificationId] is needed to verify the OTP code
  /// [phoneNumber] is the phone number where OTP was sent
  const factory AuthState.otpSent({
    required String verificationId,
    required String phoneNumber,
  }) = _OTPSent;

  /// Authentication operation in progress
  const factory AuthState.loading() = _Loading;

  /// Authentication error occurred
  /// [message] describes what went wrong
  const factory AuthState.error(String message) = _Error;
}
