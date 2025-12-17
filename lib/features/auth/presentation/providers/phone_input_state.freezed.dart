// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phone_input_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhoneInputState {

/// Currently selected country
 CountryCode? get selectedCountry;/// Phone number (formatted for display)
 String get phoneNumber;/// Raw digits only (for validation)
 String get digits;/// Whether the phone number is valid
 bool get isValid;
/// Create a copy of PhoneInputState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhoneInputStateCopyWith<PhoneInputState> get copyWith => _$PhoneInputStateCopyWithImpl<PhoneInputState>(this as PhoneInputState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhoneInputState&&(identical(other.selectedCountry, selectedCountry) || other.selectedCountry == selectedCountry)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.digits, digits) || other.digits == digits)&&(identical(other.isValid, isValid) || other.isValid == isValid));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCountry,phoneNumber,digits,isValid);

@override
String toString() {
  return 'PhoneInputState(selectedCountry: $selectedCountry, phoneNumber: $phoneNumber, digits: $digits, isValid: $isValid)';
}


}

/// @nodoc
abstract mixin class $PhoneInputStateCopyWith<$Res>  {
  factory $PhoneInputStateCopyWith(PhoneInputState value, $Res Function(PhoneInputState) _then) = _$PhoneInputStateCopyWithImpl;
@useResult
$Res call({
 CountryCode? selectedCountry, String phoneNumber, String digits, bool isValid
});


$CountryCodeCopyWith<$Res>? get selectedCountry;

}
/// @nodoc
class _$PhoneInputStateCopyWithImpl<$Res>
    implements $PhoneInputStateCopyWith<$Res> {
  _$PhoneInputStateCopyWithImpl(this._self, this._then);

  final PhoneInputState _self;
  final $Res Function(PhoneInputState) _then;

/// Create a copy of PhoneInputState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedCountry = freezed,Object? phoneNumber = null,Object? digits = null,Object? isValid = null,}) {
  return _then(_self.copyWith(
selectedCountry: freezed == selectedCountry ? _self.selectedCountry : selectedCountry // ignore: cast_nullable_to_non_nullable
as CountryCode?,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,digits: null == digits ? _self.digits : digits // ignore: cast_nullable_to_non_nullable
as String,isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PhoneInputState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountryCodeCopyWith<$Res>? get selectedCountry {
    if (_self.selectedCountry == null) {
    return null;
  }

  return $CountryCodeCopyWith<$Res>(_self.selectedCountry!, (value) {
    return _then(_self.copyWith(selectedCountry: value));
  });
}
}


/// Adds pattern-matching-related methods to [PhoneInputState].
extension PhoneInputStatePatterns on PhoneInputState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhoneInputState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhoneInputState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhoneInputState value)  $default,){
final _that = this;
switch (_that) {
case _PhoneInputState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhoneInputState value)?  $default,){
final _that = this;
switch (_that) {
case _PhoneInputState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CountryCode? selectedCountry,  String phoneNumber,  String digits,  bool isValid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhoneInputState() when $default != null:
return $default(_that.selectedCountry,_that.phoneNumber,_that.digits,_that.isValid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CountryCode? selectedCountry,  String phoneNumber,  String digits,  bool isValid)  $default,) {final _that = this;
switch (_that) {
case _PhoneInputState():
return $default(_that.selectedCountry,_that.phoneNumber,_that.digits,_that.isValid);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CountryCode? selectedCountry,  String phoneNumber,  String digits,  bool isValid)?  $default,) {final _that = this;
switch (_that) {
case _PhoneInputState() when $default != null:
return $default(_that.selectedCountry,_that.phoneNumber,_that.digits,_that.isValid);case _:
  return null;

}
}

}

/// @nodoc


class _PhoneInputState extends PhoneInputState {
  const _PhoneInputState({this.selectedCountry = null, this.phoneNumber = '', this.digits = '', this.isValid = false}): super._();
  

/// Currently selected country
@override@JsonKey() final  CountryCode? selectedCountry;
/// Phone number (formatted for display)
@override@JsonKey() final  String phoneNumber;
/// Raw digits only (for validation)
@override@JsonKey() final  String digits;
/// Whether the phone number is valid
@override@JsonKey() final  bool isValid;

/// Create a copy of PhoneInputState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhoneInputStateCopyWith<_PhoneInputState> get copyWith => __$PhoneInputStateCopyWithImpl<_PhoneInputState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhoneInputState&&(identical(other.selectedCountry, selectedCountry) || other.selectedCountry == selectedCountry)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.digits, digits) || other.digits == digits)&&(identical(other.isValid, isValid) || other.isValid == isValid));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCountry,phoneNumber,digits,isValid);

@override
String toString() {
  return 'PhoneInputState(selectedCountry: $selectedCountry, phoneNumber: $phoneNumber, digits: $digits, isValid: $isValid)';
}


}

/// @nodoc
abstract mixin class _$PhoneInputStateCopyWith<$Res> implements $PhoneInputStateCopyWith<$Res> {
  factory _$PhoneInputStateCopyWith(_PhoneInputState value, $Res Function(_PhoneInputState) _then) = __$PhoneInputStateCopyWithImpl;
@override @useResult
$Res call({
 CountryCode? selectedCountry, String phoneNumber, String digits, bool isValid
});


@override $CountryCodeCopyWith<$Res>? get selectedCountry;

}
/// @nodoc
class __$PhoneInputStateCopyWithImpl<$Res>
    implements _$PhoneInputStateCopyWith<$Res> {
  __$PhoneInputStateCopyWithImpl(this._self, this._then);

  final _PhoneInputState _self;
  final $Res Function(_PhoneInputState) _then;

/// Create a copy of PhoneInputState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedCountry = freezed,Object? phoneNumber = null,Object? digits = null,Object? isValid = null,}) {
  return _then(_PhoneInputState(
selectedCountry: freezed == selectedCountry ? _self.selectedCountry : selectedCountry // ignore: cast_nullable_to_non_nullable
as CountryCode?,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,digits: null == digits ? _self.digits : digits // ignore: cast_nullable_to_non_nullable
as String,isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PhoneInputState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CountryCodeCopyWith<$Res>? get selectedCountry {
    if (_self.selectedCountry == null) {
    return null;
  }

  return $CountryCodeCopyWith<$Res>(_self.selectedCountry!, (value) {
    return _then(_self.copyWith(selectedCountry: value));
  });
}
}

// dart format on
