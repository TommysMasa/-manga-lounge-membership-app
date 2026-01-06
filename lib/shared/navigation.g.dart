// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(navigation)
const navigationProvider = NavigationProvider._();

final class NavigationProvider
    extends
        $FunctionalProvider<NavigationState, NavigationState, NavigationState>
    with $Provider<NavigationState> {
  const NavigationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationHash();

  @$internal
  @override
  $ProviderElement<NavigationState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NavigationState create(Ref ref) {
    return navigation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationState>(value),
    );
  }
}

String _$navigationHash() => r'6247bef0b28e493bfdcddc0270080db387100c29';
