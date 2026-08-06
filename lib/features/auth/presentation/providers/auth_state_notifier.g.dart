// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(AuthStateNotifier)
const authStateProvider = AuthStateNotifierProvider._();

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
final class AuthStateNotifierProvider
    extends $NotifierProvider<AuthStateNotifier, AuthState> {
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
  const AuthStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateNotifierHash();

  @$internal
  @override
  AuthStateNotifier create() => AuthStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authStateNotifierHash() => r'b1230c2fecd6b5bcc09244a6c66ed49eb2bad7ea';

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

abstract class _$AuthStateNotifier extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
