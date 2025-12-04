// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'country_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CountryCode {

/// Country name (e.g., "United States", "Japan")
 String get name;/// ISO country code (e.g., "US", "JP")
 String get isoCode;/// International dialing code (e.g., "+1", "+81")
 String get dialCode;/// Country flag emoji (e.g., "🇺🇸", "🇯🇵")
 String get flagEmoji;/// Expected phone number length (excluding country code)
/// For countries with variable length, use the most common length
 int get phoneLength;/// Hint text showing the expected format
/// e.g., "(555) 123-4567" for US, "80-1234-5678" for Japan
 String get formatHint;
/// Create a copy of CountryCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CountryCodeCopyWith<CountryCode> get copyWith => _$CountryCodeCopyWithImpl<CountryCode>(this as CountryCode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CountryCode&&(identical(other.name, name) || other.name == name)&&(identical(other.isoCode, isoCode) || other.isoCode == isoCode)&&(identical(other.dialCode, dialCode) || other.dialCode == dialCode)&&(identical(other.flagEmoji, flagEmoji) || other.flagEmoji == flagEmoji)&&(identical(other.phoneLength, phoneLength) || other.phoneLength == phoneLength)&&(identical(other.formatHint, formatHint) || other.formatHint == formatHint));
}


@override
int get hashCode => Object.hash(runtimeType,name,isoCode,dialCode,flagEmoji,phoneLength,formatHint);

@override
String toString() {
  return 'CountryCode(name: $name, isoCode: $isoCode, dialCode: $dialCode, flagEmoji: $flagEmoji, phoneLength: $phoneLength, formatHint: $formatHint)';
}


}

/// @nodoc
abstract mixin class $CountryCodeCopyWith<$Res>  {
  factory $CountryCodeCopyWith(CountryCode value, $Res Function(CountryCode) _then) = _$CountryCodeCopyWithImpl;
@useResult
$Res call({
 String name, String isoCode, String dialCode, String flagEmoji, int phoneLength, String formatHint
});




}
/// @nodoc
class _$CountryCodeCopyWithImpl<$Res>
    implements $CountryCodeCopyWith<$Res> {
  _$CountryCodeCopyWithImpl(this._self, this._then);

  final CountryCode _self;
  final $Res Function(CountryCode) _then;

/// Create a copy of CountryCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? isoCode = null,Object? dialCode = null,Object? flagEmoji = null,Object? phoneLength = null,Object? formatHint = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isoCode: null == isoCode ? _self.isoCode : isoCode // ignore: cast_nullable_to_non_nullable
as String,dialCode: null == dialCode ? _self.dialCode : dialCode // ignore: cast_nullable_to_non_nullable
as String,flagEmoji: null == flagEmoji ? _self.flagEmoji : flagEmoji // ignore: cast_nullable_to_non_nullable
as String,phoneLength: null == phoneLength ? _self.phoneLength : phoneLength // ignore: cast_nullable_to_non_nullable
as int,formatHint: null == formatHint ? _self.formatHint : formatHint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CountryCode].
extension CountryCodePatterns on CountryCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CountryCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CountryCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CountryCode value)  $default,){
final _that = this;
switch (_that) {
case _CountryCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CountryCode value)?  $default,){
final _that = this;
switch (_that) {
case _CountryCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String isoCode,  String dialCode,  String flagEmoji,  int phoneLength,  String formatHint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CountryCode() when $default != null:
return $default(_that.name,_that.isoCode,_that.dialCode,_that.flagEmoji,_that.phoneLength,_that.formatHint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String isoCode,  String dialCode,  String flagEmoji,  int phoneLength,  String formatHint)  $default,) {final _that = this;
switch (_that) {
case _CountryCode():
return $default(_that.name,_that.isoCode,_that.dialCode,_that.flagEmoji,_that.phoneLength,_that.formatHint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String isoCode,  String dialCode,  String flagEmoji,  int phoneLength,  String formatHint)?  $default,) {final _that = this;
switch (_that) {
case _CountryCode() when $default != null:
return $default(_that.name,_that.isoCode,_that.dialCode,_that.flagEmoji,_that.phoneLength,_that.formatHint);case _:
  return null;

}
}

}

/// @nodoc


class _CountryCode extends CountryCode {
  const _CountryCode({required this.name, required this.isoCode, required this.dialCode, required this.flagEmoji, required this.phoneLength, required this.formatHint}): super._();
  

/// Country name (e.g., "United States", "Japan")
@override final  String name;
/// ISO country code (e.g., "US", "JP")
@override final  String isoCode;
/// International dialing code (e.g., "+1", "+81")
@override final  String dialCode;
/// Country flag emoji (e.g., "🇺🇸", "🇯🇵")
@override final  String flagEmoji;
/// Expected phone number length (excluding country code)
/// For countries with variable length, use the most common length
@override final  int phoneLength;
/// Hint text showing the expected format
/// e.g., "(555) 123-4567" for US, "80-1234-5678" for Japan
@override final  String formatHint;

/// Create a copy of CountryCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CountryCodeCopyWith<_CountryCode> get copyWith => __$CountryCodeCopyWithImpl<_CountryCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CountryCode&&(identical(other.name, name) || other.name == name)&&(identical(other.isoCode, isoCode) || other.isoCode == isoCode)&&(identical(other.dialCode, dialCode) || other.dialCode == dialCode)&&(identical(other.flagEmoji, flagEmoji) || other.flagEmoji == flagEmoji)&&(identical(other.phoneLength, phoneLength) || other.phoneLength == phoneLength)&&(identical(other.formatHint, formatHint) || other.formatHint == formatHint));
}


@override
int get hashCode => Object.hash(runtimeType,name,isoCode,dialCode,flagEmoji,phoneLength,formatHint);

@override
String toString() {
  return 'CountryCode(name: $name, isoCode: $isoCode, dialCode: $dialCode, flagEmoji: $flagEmoji, phoneLength: $phoneLength, formatHint: $formatHint)';
}


}

/// @nodoc
abstract mixin class _$CountryCodeCopyWith<$Res> implements $CountryCodeCopyWith<$Res> {
  factory _$CountryCodeCopyWith(_CountryCode value, $Res Function(_CountryCode) _then) = __$CountryCodeCopyWithImpl;
@override @useResult
$Res call({
 String name, String isoCode, String dialCode, String flagEmoji, int phoneLength, String formatHint
});




}
/// @nodoc
class __$CountryCodeCopyWithImpl<$Res>
    implements _$CountryCodeCopyWith<$Res> {
  __$CountryCodeCopyWithImpl(this._self, this._then);

  final _CountryCode _self;
  final $Res Function(_CountryCode) _then;

/// Create a copy of CountryCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? isoCode = null,Object? dialCode = null,Object? flagEmoji = null,Object? phoneLength = null,Object? formatHint = null,}) {
  return _then(_CountryCode(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isoCode: null == isoCode ? _self.isoCode : isoCode // ignore: cast_nullable_to_non_nullable
as String,dialCode: null == dialCode ? _self.dialCode : dialCode // ignore: cast_nullable_to_non_nullable
as String,flagEmoji: null == flagEmoji ? _self.flagEmoji : flagEmoji // ignore: cast_nullable_to_non_nullable
as String,phoneLength: null == phoneLength ? _self.phoneLength : phoneLength // ignore: cast_nullable_to_non_nullable
as int,formatHint: null == formatHint ? _self.formatHint : formatHint // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
