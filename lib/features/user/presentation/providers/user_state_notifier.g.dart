// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_state_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State notifier for managing user-related state using Riverpod codegen
///
/// This class:
/// 1. Manages the user state for the UI
/// 2. Calls use cases to perform business logic
/// 3. Updates state based on use case results
/// 4. Handles both success and failure scenarios

@ProviderFor(UserStateNotifier)
const userStateProvider = UserStateNotifierProvider._();

/// State notifier for managing user-related state using Riverpod codegen
///
/// This class:
/// 1. Manages the user state for the UI
/// 2. Calls use cases to perform business logic
/// 3. Updates state based on use case results
/// 4. Handles both success and failure scenarios
final class UserStateNotifierProvider
    extends $NotifierProvider<UserStateNotifier, UserState> {
  /// State notifier for managing user-related state using Riverpod codegen
  ///
  /// This class:
  /// 1. Manages the user state for the UI
  /// 2. Calls use cases to perform business logic
  /// 3. Updates state based on use case results
  /// 4. Handles both success and failure scenarios
  const UserStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userStateNotifierHash();

  @$internal
  @override
  UserStateNotifier create() => UserStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserState>(value),
    );
  }
}

String _$userStateNotifierHash() => r'94245dfabb429d173966c922cbea2cc80fc04f41';

/// State notifier for managing user-related state using Riverpod codegen
///
/// This class:
/// 1. Manages the user state for the UI
/// 2. Calls use cases to perform business logic
/// 3. Updates state based on use case results
/// 4. Handles both success and failure scenarios

abstract class _$UserStateNotifier extends $Notifier<UserState> {
  UserState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UserState, UserState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserState, UserState>,
              UserState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
