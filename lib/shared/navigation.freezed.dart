// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'navigation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NavigationState {

 GlobalKey<NavigatorState> get rootNavKey;
/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationStateCopyWith<NavigationState> get copyWith => _$NavigationStateCopyWithImpl<NavigationState>(this as NavigationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationState&&(identical(other.rootNavKey, rootNavKey) || other.rootNavKey == rootNavKey));
}


@override
int get hashCode => Object.hash(runtimeType,rootNavKey);

@override
String toString() {
  return 'NavigationState(rootNavKey: $rootNavKey)';
}


}

/// @nodoc
abstract mixin class $NavigationStateCopyWith<$Res>  {
  factory $NavigationStateCopyWith(NavigationState value, $Res Function(NavigationState) _then) = _$NavigationStateCopyWithImpl;
@useResult
$Res call({
 GlobalKey<NavigatorState> rootNavKey
});




}
/// @nodoc
class _$NavigationStateCopyWithImpl<$Res>
    implements $NavigationStateCopyWith<$Res> {
  _$NavigationStateCopyWithImpl(this._self, this._then);

  final NavigationState _self;
  final $Res Function(NavigationState) _then;

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rootNavKey = null,}) {
  return _then(_self.copyWith(
rootNavKey: null == rootNavKey ? _self.rootNavKey : rootNavKey // ignore: cast_nullable_to_non_nullable
as GlobalKey<NavigatorState>,
  ));
}

}


/// Adds pattern-matching-related methods to [NavigationState].
extension NavigationStatePatterns on NavigationState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavigationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavigationState value)  $default,){
final _that = this;
switch (_that) {
case _NavigationState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavigationState value)?  $default,){
final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GlobalKey<NavigatorState> rootNavKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
return $default(_that.rootNavKey);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GlobalKey<NavigatorState> rootNavKey)  $default,) {final _that = this;
switch (_that) {
case _NavigationState():
return $default(_that.rootNavKey);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GlobalKey<NavigatorState> rootNavKey)?  $default,) {final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
return $default(_that.rootNavKey);case _:
  return null;

}
}

}

/// @nodoc


class _NavigationState extends NavigationState {
   _NavigationState({required this.rootNavKey}): super._();
  

@override final  GlobalKey<NavigatorState> rootNavKey;

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationStateCopyWith<_NavigationState> get copyWith => __$NavigationStateCopyWithImpl<_NavigationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationState&&(identical(other.rootNavKey, rootNavKey) || other.rootNavKey == rootNavKey));
}


@override
int get hashCode => Object.hash(runtimeType,rootNavKey);

@override
String toString() {
  return 'NavigationState(rootNavKey: $rootNavKey)';
}


}

/// @nodoc
abstract mixin class _$NavigationStateCopyWith<$Res> implements $NavigationStateCopyWith<$Res> {
  factory _$NavigationStateCopyWith(_NavigationState value, $Res Function(_NavigationState) _then) = __$NavigationStateCopyWithImpl;
@override @useResult
$Res call({
 GlobalKey<NavigatorState> rootNavKey
});




}
/// @nodoc
class __$NavigationStateCopyWithImpl<$Res>
    implements _$NavigationStateCopyWith<$Res> {
  __$NavigationStateCopyWithImpl(this._self, this._then);

  final _NavigationState _self;
  final $Res Function(_NavigationState) _then;

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rootNavKey = null,}) {
  return _then(_NavigationState(
rootNavKey: null == rootNavKey ? _self.rootNavKey : rootNavKey // ignore: cast_nullable_to_non_nullable
as GlobalKey<NavigatorState>,
  ));
}


}

// dart format on
