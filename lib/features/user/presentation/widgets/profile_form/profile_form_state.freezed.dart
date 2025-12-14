// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileFormState {

 ProfileFormMode get mode; String get firstName; String get lastName; String get email; Gender? get gender; DateTime? get dateOfBirth; String get phoneNumber; bool get hasChanges; bool get isSubmitting; String? get errorMessage;
/// Create a copy of ProfileFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileFormStateCopyWith<ProfileFormState> get copyWith => _$ProfileFormStateCopyWithImpl<ProfileFormState>(this as ProfileFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileFormState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.hasChanges, hasChanges) || other.hasChanges == hasChanges)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,mode,firstName,lastName,email,gender,dateOfBirth,phoneNumber,hasChanges,isSubmitting,errorMessage);

@override
String toString() {
  return 'ProfileFormState(mode: $mode, firstName: $firstName, lastName: $lastName, email: $email, gender: $gender, dateOfBirth: $dateOfBirth, phoneNumber: $phoneNumber, hasChanges: $hasChanges, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ProfileFormStateCopyWith<$Res>  {
  factory $ProfileFormStateCopyWith(ProfileFormState value, $Res Function(ProfileFormState) _then) = _$ProfileFormStateCopyWithImpl;
@useResult
$Res call({
 ProfileFormMode mode, String firstName, String lastName, String email, Gender? gender, DateTime? dateOfBirth, String phoneNumber, bool hasChanges, bool isSubmitting, String? errorMessage
});




}
/// @nodoc
class _$ProfileFormStateCopyWithImpl<$Res>
    implements $ProfileFormStateCopyWith<$Res> {
  _$ProfileFormStateCopyWithImpl(this._self, this._then);

  final ProfileFormState _self;
  final $Res Function(ProfileFormState) _then;

/// Create a copy of ProfileFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? gender = freezed,Object? dateOfBirth = freezed,Object? phoneNumber = null,Object? hasChanges = null,Object? isSubmitting = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ProfileFormMode,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,hasChanges: null == hasChanges ? _self.hasChanges : hasChanges // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileFormState].
extension ProfileFormStatePatterns on ProfileFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileFormState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileFormState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProfileFormMode mode,  String firstName,  String lastName,  String email,  Gender? gender,  DateTime? dateOfBirth,  String phoneNumber,  bool hasChanges,  bool isSubmitting,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileFormState() when $default != null:
return $default(_that.mode,_that.firstName,_that.lastName,_that.email,_that.gender,_that.dateOfBirth,_that.phoneNumber,_that.hasChanges,_that.isSubmitting,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProfileFormMode mode,  String firstName,  String lastName,  String email,  Gender? gender,  DateTime? dateOfBirth,  String phoneNumber,  bool hasChanges,  bool isSubmitting,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ProfileFormState():
return $default(_that.mode,_that.firstName,_that.lastName,_that.email,_that.gender,_that.dateOfBirth,_that.phoneNumber,_that.hasChanges,_that.isSubmitting,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProfileFormMode mode,  String firstName,  String lastName,  String email,  Gender? gender,  DateTime? dateOfBirth,  String phoneNumber,  bool hasChanges,  bool isSubmitting,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ProfileFormState() when $default != null:
return $default(_that.mode,_that.firstName,_that.lastName,_that.email,_that.gender,_that.dateOfBirth,_that.phoneNumber,_that.hasChanges,_that.isSubmitting,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileFormState extends ProfileFormState {
  const _ProfileFormState({required this.mode, this.firstName = '', this.lastName = '', this.email = '', this.gender, this.dateOfBirth, this.phoneNumber = '', this.hasChanges = false, this.isSubmitting = false, this.errorMessage}): super._();
  

@override final  ProfileFormMode mode;
@override@JsonKey() final  String firstName;
@override@JsonKey() final  String lastName;
@override@JsonKey() final  String email;
@override final  Gender? gender;
@override final  DateTime? dateOfBirth;
@override@JsonKey() final  String phoneNumber;
@override@JsonKey() final  bool hasChanges;
@override@JsonKey() final  bool isSubmitting;
@override final  String? errorMessage;

/// Create a copy of ProfileFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileFormStateCopyWith<_ProfileFormState> get copyWith => __$ProfileFormStateCopyWithImpl<_ProfileFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileFormState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.hasChanges, hasChanges) || other.hasChanges == hasChanges)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,mode,firstName,lastName,email,gender,dateOfBirth,phoneNumber,hasChanges,isSubmitting,errorMessage);

@override
String toString() {
  return 'ProfileFormState(mode: $mode, firstName: $firstName, lastName: $lastName, email: $email, gender: $gender, dateOfBirth: $dateOfBirth, phoneNumber: $phoneNumber, hasChanges: $hasChanges, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ProfileFormStateCopyWith<$Res> implements $ProfileFormStateCopyWith<$Res> {
  factory _$ProfileFormStateCopyWith(_ProfileFormState value, $Res Function(_ProfileFormState) _then) = __$ProfileFormStateCopyWithImpl;
@override @useResult
$Res call({
 ProfileFormMode mode, String firstName, String lastName, String email, Gender? gender, DateTime? dateOfBirth, String phoneNumber, bool hasChanges, bool isSubmitting, String? errorMessage
});




}
/// @nodoc
class __$ProfileFormStateCopyWithImpl<$Res>
    implements _$ProfileFormStateCopyWith<$Res> {
  __$ProfileFormStateCopyWithImpl(this._self, this._then);

  final _ProfileFormState _self;
  final $Res Function(_ProfileFormState) _then;

/// Create a copy of ProfileFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? gender = freezed,Object? dateOfBirth = freezed,Object? phoneNumber = null,Object? hasChanges = null,Object? isSubmitting = null,Object? errorMessage = freezed,}) {
  return _then(_ProfileFormState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ProfileFormMode,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,hasChanges: null == hasChanges ? _self.hasChanges : hasChanges // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
