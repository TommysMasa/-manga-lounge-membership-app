import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../domain/entities/auth_state.dart';

part 'auth_state_notifier.g.dart';

/// Auth State Notifier
///
/// Manages authentication state for the presentation layer using Riverpod codegen.
/// This replaces the old AuthProvider (ChangeNotifier).
///
/// Responsibilities:
/// - Hold current AuthState
/// - Execute auth use cases
/// - Update state based on results
/// - Listen to auth state changes
///
/// UI screens will watch this provider and react to state changes.
@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  StreamSubscription<dynamic>? _authStateSubscription;

  @override
  AuthState build() {
    // Dispose subscription when provider is disposed
    ref.onDispose(() {
      _authStateSubscription?.cancel();
    });

    // Listen to auth state changes when notifier is created
    _listenToAuthState();

    // Return initial state
    return const AuthState.initial();
  }

  /// Listen to authentication state changes from repository
  void _listenToAuthState() {
    final watchAuthState = ref.read(watchAuthStateProvider);
    _authStateSubscription = watchAuthState.call().listen((either) {
      either.fold(
        (failure) {
          // Auth state monitoring failed
          state = AuthState.error(failure.message);
        },
        (uid) {
          if (uid != null) {
            // User is authenticated
            state = AuthState.authenticated(uid);
          } else {
            // User is not authenticated
            state = const AuthState.unauthenticated();
          }
        },
      );
    });
  }

  /// Send OTP to phone number
  Future<void> sendOTPCode(String phoneNumber) async {
    state = const AuthState.loading();

    final sendOTP = ref.read(sendOTPProvider);
    final result = await sendOTP.call(phoneNumber);

    result.fold(
      (failure) {
        // OTP sending failed
        state = AuthState.error(failure.message);
      },
      (verificationId) {
        // OTP sent successfully
        state = AuthState.otpSent(
          verificationId: verificationId,
          phoneNumber: phoneNumber,
        );
      },
    );
  }

  /// Verify OTP code
  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    state = const AuthState.loading();

    final verifyOTP = ref.read(verifyOTPProvider);
    final result = await verifyOTP.call(
      verificationId: verificationId,
      otpCode: otpCode,
    );

    result.fold(
      (failure) {
        // OTP verification failed
        state = AuthState.error(failure.message);
      },
      (uid) {
        // OTP verified successfully - user is now authenticated
        // The authStateChanges stream will update the state to authenticated
      },
    );
  }

  /// Sign out current user
  Future<void> signOutUser() async {
    state = const AuthState.loading();

    final signOut = ref.read(signOutProvider);
    final result = await signOut.call();

    result.fold(
      (failure) {
        // Sign out failed
        state = AuthState.error(failure.message);
      },
      (_) {
        // Sign out successful
        // The authStateChanges stream will update the state to unauthenticated
      },
    );
  }

  /// Reset state to initial
  void resetState() {
    state = const AuthState.initial();
  }

  /// Clear error and return to unauthenticated state
  void clearError() {
    state = const AuthState.unauthenticated();
  }
}
