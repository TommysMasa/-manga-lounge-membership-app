// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_form_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing profile form state
///
/// Handles form lifecycle for both create and edit modes:
/// - Field updates
/// - Change detection
/// - Form submission (delegates to UserStateNotifier)

@ProviderFor(ProfileFormNotifier)
const profileFormProvider = ProfileFormNotifierProvider._();

/// Notifier for managing profile form state
///
/// Handles form lifecycle for both create and edit modes:
/// - Field updates
/// - Change detection
/// - Form submission (delegates to UserStateNotifier)
final class ProfileFormNotifierProvider
    extends $NotifierProvider<ProfileFormNotifier, ProfileFormState> {
  /// Notifier for managing profile form state
  ///
  /// Handles form lifecycle for both create and edit modes:
  /// - Field updates
  /// - Change detection
  /// - Form submission (delegates to UserStateNotifier)
  const ProfileFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileFormNotifierHash();

  @$internal
  @override
  ProfileFormNotifier create() => ProfileFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileFormState>(value),
    );
  }
}

String _$profileFormNotifierHash() =>
    r'85e229728651b24ddd6ac97139fe637fb128972c';

/// Notifier for managing profile form state
///
/// Handles form lifecycle for both create and edit modes:
/// - Field updates
/// - Change detection
/// - Form submission (delegates to UserStateNotifier)

abstract class _$ProfileFormNotifier extends $Notifier<ProfileFormState> {
  ProfileFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProfileFormState, ProfileFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProfileFormState, ProfileFormState>,
              ProfileFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
