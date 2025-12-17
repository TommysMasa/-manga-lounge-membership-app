// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_input_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for phone number input
///
/// Handles:
/// - Phone number formatting per country
/// - Country selection
/// - Autofill detection and processing
/// - Validation

@ProviderFor(PhoneInputNotifier)
const phoneInputProvider = PhoneInputNotifierProvider._();

/// Notifier for phone number input
///
/// Handles:
/// - Phone number formatting per country
/// - Country selection
/// - Autofill detection and processing
/// - Validation
final class PhoneInputNotifierProvider
    extends $NotifierProvider<PhoneInputNotifier, PhoneInputState> {
  /// Notifier for phone number input
  ///
  /// Handles:
  /// - Phone number formatting per country
  /// - Country selection
  /// - Autofill detection and processing
  /// - Validation
  const PhoneInputNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'phoneInputProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$phoneInputNotifierHash();

  @$internal
  @override
  PhoneInputNotifier create() => PhoneInputNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhoneInputState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhoneInputState>(value),
    );
  }
}

String _$phoneInputNotifierHash() =>
    r'121f5640be4f9cb1f22e86eda13d66b4b74603b7';

/// Notifier for phone number input
///
/// Handles:
/// - Phone number formatting per country
/// - Country selection
/// - Autofill detection and processing
/// - Validation

abstract class _$PhoneInputNotifier extends $Notifier<PhoneInputState> {
  PhoneInputState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PhoneInputState, PhoneInputState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PhoneInputState, PhoneInputState>,
              PhoneInputState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
