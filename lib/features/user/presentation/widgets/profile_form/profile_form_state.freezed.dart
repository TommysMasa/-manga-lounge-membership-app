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

 ProfileFormMode get mode; String get firstName; String get lastName; String get email; Gender? get gender; DateTime? get dateOfBirth; ReferralSource? get referralSource; String get zipcode; String get phoneNumber; bool get hasChanges; bool get isSubmitting; String? get errorMessage;// Initial values for change detection (edit mode only)
 String get initialFirstName; String get initialLastName; String get initialEmail; Gender? get initialGender; DateTime? get initialDateOfBirth; ReferralSource? get initialReferralSource; String get initialZipcode;
/// Create a copy of ProfileFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileFormStateCopyWith<ProfileFormState> get copyWith => _$ProfileFormStateCopyWithImpl<ProfileFormState>(this as ProfileFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileFormState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.referralSource, referralSource) || other.referralSource == referralSource)&&(identical(other.zipcode, zipcode) || other.zipcode == zipcode)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.hasChanges, hasChanges) || other.hasChanges == hasChanges)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.initialFirstName, initialFirstName) || other.initialFirstName == initialFirstName)&&(identical(other.initialLastName, initialLastName) || other.initialLastName == initialLastName)&&(identical(other.initialEmail, initialEmail) || other.initialEmail == initialEmail)&&(identical(other.initialGender, initialGender) || other.initialGender == initialGender)&&(identical(other.initialDateOfBirth, initialDateOfBirth) || other.initialDateOfBirth == initialDateOfBirth)&&(identical(other.initialReferralSource, initialReferralSource) || other.initialReferralSource == initialReferralSource)&&(identical(other.initialZipcode, initialZipcode) || other.initialZipcode == initialZipcode));
}


@override
int get hashCode => Object.hashAll([runtimeType,mode,firstName,lastName,email,gender,dateOfBirth,referralSource,zipcode,phoneNumber,hasChanges,isSubmitting,errorMessage,initialFirstName,initialLastName,initialEmail,initialGender,initialDateOfBirth,initialReferralSource,initialZipcode]);

@override
String toString() {
  return 'ProfileFormState(mode: $mode, firstName: $firstName, lastName: $lastName, email: $email, gender: $gender, dateOfBirth: $dateOfBirth, referralSource: $referralSource, zipcode: $zipcode, phoneNumber: $phoneNumber, hasChanges: $hasChanges, isSubmitting: $isSubmitting, errorMessage: $errorMessage, initialFirstName: $initialFirstName, initialLastName: $initialLastName, initialEmail: $initialEmail, initialGender: $initialGender, initialDateOfBirth: $initialDateOfBirth, initialReferralSource: $initialReferralSource, initialZipcode: $initialZipcode)';
}


}

/// @nodoc
abstract mixin class $ProfileFormStateCopyWith<$Res>  {
  factory $ProfileFormStateCopyWith(ProfileFormState value, $Res Function(ProfileFormState) _then) = _$ProfileFormStateCopyWithImpl;
@useResult
$Res call({
 ProfileFormMode mode, String firstName, String lastName, String email, Gender? gender, DateTime? dateOfBirth, ReferralSource? referralSource, String zipcode, String phoneNumber, bool hasChanges, bool isSubmitting, String? errorMessage, String initialFirstName, String initialLastName, String initialEmail, Gender? initialGender, DateTime? initialDateOfBirth, ReferralSource? initialReferralSource, String initialZipcode
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
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? gender = freezed,Object? dateOfBirth = freezed,Object? referralSource = freezed,Object? zipcode = null,Object? phoneNumber = null,Object? hasChanges = null,Object? isSubmitting = null,Object? errorMessage = freezed,Object? initialFirstName = null,Object? initialLastName = null,Object? initialEmail = null,Object? initialGender = freezed,Object? initialDateOfBirth = freezed,Object? initialReferralSource = freezed,Object? initialZipcode = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ProfileFormMode,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,referralSource: freezed == referralSource ? _self.referralSource : referralSource // ignore: cast_nullable_to_non_nullable
as ReferralSource?,zipcode: null == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,hasChanges: null == hasChanges ? _self.hasChanges : hasChanges // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,initialFirstName: null == initialFirstName ? _self.initialFirstName : initialFirstName // ignore: cast_nullable_to_non_nullable
as String,initialLastName: null == initialLastName ? _self.initialLastName : initialLastName // ignore: cast_nullable_to_non_nullable
as String,initialEmail: null == initialEmail ? _self.initialEmail : initialEmail // ignore: cast_nullable_to_non_nullable
as String,initialGender: freezed == initialGender ? _self.initialGender : initialGender // ignore: cast_nullable_to_non_nullable
as Gender?,initialDateOfBirth: freezed == initialDateOfBirth ? _self.initialDateOfBirth : initialDateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,initialReferralSource: freezed == initialReferralSource ? _self.initialReferralSource : initialReferralSource // ignore: cast_nullable_to_non_nullable
as ReferralSource?,initialZipcode: null == initialZipcode ? _self.initialZipcode : initialZipcode // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProfileFormMode mode,  String firstName,  String lastName,  String email,  Gender? gender,  DateTime? dateOfBirth,  ReferralSource? referralSource,  String zipcode,  String phoneNumber,  bool hasChanges,  bool isSubmitting,  String? errorMessage,  String initialFirstName,  String initialLastName,  String initialEmail,  Gender? initialGender,  DateTime? initialDateOfBirth,  ReferralSource? initialReferralSource,  String initialZipcode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileFormState() when $default != null:
return $default(_that.mode,_that.firstName,_that.lastName,_that.email,_that.gender,_that.dateOfBirth,_that.referralSource,_that.zipcode,_that.phoneNumber,_that.hasChanges,_that.isSubmitting,_that.errorMessage,_that.initialFirstName,_that.initialLastName,_that.initialEmail,_that.initialGender,_that.initialDateOfBirth,_that.initialReferralSource,_that.initialZipcode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProfileFormMode mode,  String firstName,  String lastName,  String email,  Gender? gender,  DateTime? dateOfBirth,  ReferralSource? referralSource,  String zipcode,  String phoneNumber,  bool hasChanges,  bool isSubmitting,  String? errorMessage,  String initialFirstName,  String initialLastName,  String initialEmail,  Gender? initialGender,  DateTime? initialDateOfBirth,  ReferralSource? initialReferralSource,  String initialZipcode)  $default,) {final _that = this;
switch (_that) {
case _ProfileFormState():
return $default(_that.mode,_that.firstName,_that.lastName,_that.email,_that.gender,_that.dateOfBirth,_that.referralSource,_that.zipcode,_that.phoneNumber,_that.hasChanges,_that.isSubmitting,_that.errorMessage,_that.initialFirstName,_that.initialLastName,_that.initialEmail,_that.initialGender,_that.initialDateOfBirth,_that.initialReferralSource,_that.initialZipcode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProfileFormMode mode,  String firstName,  String lastName,  String email,  Gender? gender,  DateTime? dateOfBirth,  ReferralSource? referralSource,  String zipcode,  String phoneNumber,  bool hasChanges,  bool isSubmitting,  String? errorMessage,  String initialFirstName,  String initialLastName,  String initialEmail,  Gender? initialGender,  DateTime? initialDateOfBirth,  ReferralSource? initialReferralSource,  String initialZipcode)?  $default,) {final _that = this;
switch (_that) {
case _ProfileFormState() when $default != null:
return $default(_that.mode,_that.firstName,_that.lastName,_that.email,_that.gender,_that.dateOfBirth,_that.referralSource,_that.zipcode,_that.phoneNumber,_that.hasChanges,_that.isSubmitting,_that.errorMessage,_that.initialFirstName,_that.initialLastName,_that.initialEmail,_that.initialGender,_that.initialDateOfBirth,_that.initialReferralSource,_that.initialZipcode);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileFormState extends ProfileFormState {
  const _ProfileFormState({required this.mode, this.firstName = '', this.lastName = '', this.email = '', this.gender, this.dateOfBirth, this.referralSource, this.zipcode = '', this.phoneNumber = '', this.hasChanges = false, this.isSubmitting = false, this.errorMessage, this.initialFirstName = '', this.initialLastName = '', this.initialEmail = '', this.initialGender, this.initialDateOfBirth, this.initialReferralSource, this.initialZipcode = ''}): super._();
  

@override final  ProfileFormMode mode;
@override@JsonKey() final  String firstName;
@override@JsonKey() final  String lastName;
@override@JsonKey() final  String email;
@override final  Gender? gender;
@override final  DateTime? dateOfBirth;
@override final  ReferralSource? referralSource;
@override@JsonKey() final  String zipcode;
@override@JsonKey() final  String phoneNumber;
@override@JsonKey() final  bool hasChanges;
@override@JsonKey() final  bool isSubmitting;
@override final  String? errorMessage;
// Initial values for change detection (edit mode only)
@override@JsonKey() final  String initialFirstName;
@override@JsonKey() final  String initialLastName;
@override@JsonKey() final  String initialEmail;
@override final  Gender? initialGender;
@override final  DateTime? initialDateOfBirth;
@override final  ReferralSource? initialReferralSource;
@override@JsonKey() final  String initialZipcode;

/// Create a copy of ProfileFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileFormStateCopyWith<_ProfileFormState> get copyWith => __$ProfileFormStateCopyWithImpl<_ProfileFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileFormState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.referralSource, referralSource) || other.referralSource == referralSource)&&(identical(other.zipcode, zipcode) || other.zipcode == zipcode)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.hasChanges, hasChanges) || other.hasChanges == hasChanges)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.initialFirstName, initialFirstName) || other.initialFirstName == initialFirstName)&&(identical(other.initialLastName, initialLastName) || other.initialLastName == initialLastName)&&(identical(other.initialEmail, initialEmail) || other.initialEmail == initialEmail)&&(identical(other.initialGender, initialGender) || other.initialGender == initialGender)&&(identical(other.initialDateOfBirth, initialDateOfBirth) || other.initialDateOfBirth == initialDateOfBirth)&&(identical(other.initialReferralSource, initialReferralSource) || other.initialReferralSource == initialReferralSource)&&(identical(other.initialZipcode, initialZipcode) || other.initialZipcode == initialZipcode));
}


@override
int get hashCode => Object.hashAll([runtimeType,mode,firstName,lastName,email,gender,dateOfBirth,referralSource,zipcode,phoneNumber,hasChanges,isSubmitting,errorMessage,initialFirstName,initialLastName,initialEmail,initialGender,initialDateOfBirth,initialReferralSource,initialZipcode]);

@override
String toString() {
  return 'ProfileFormState(mode: $mode, firstName: $firstName, lastName: $lastName, email: $email, gender: $gender, dateOfBirth: $dateOfBirth, referralSource: $referralSource, zipcode: $zipcode, phoneNumber: $phoneNumber, hasChanges: $hasChanges, isSubmitting: $isSubmitting, errorMessage: $errorMessage, initialFirstName: $initialFirstName, initialLastName: $initialLastName, initialEmail: $initialEmail, initialGender: $initialGender, initialDateOfBirth: $initialDateOfBirth, initialReferralSource: $initialReferralSource, initialZipcode: $initialZipcode)';
}


}

/// @nodoc
abstract mixin class _$ProfileFormStateCopyWith<$Res> implements $ProfileFormStateCopyWith<$Res> {
  factory _$ProfileFormStateCopyWith(_ProfileFormState value, $Res Function(_ProfileFormState) _then) = __$ProfileFormStateCopyWithImpl;
@override @useResult
$Res call({
 ProfileFormMode mode, String firstName, String lastName, String email, Gender? gender, DateTime? dateOfBirth, ReferralSource? referralSource, String zipcode, String phoneNumber, bool hasChanges, bool isSubmitting, String? errorMessage, String initialFirstName, String initialLastName, String initialEmail, Gender? initialGender, DateTime? initialDateOfBirth, ReferralSource? initialReferralSource, String initialZipcode
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
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? gender = freezed,Object? dateOfBirth = freezed,Object? referralSource = freezed,Object? zipcode = null,Object? phoneNumber = null,Object? hasChanges = null,Object? isSubmitting = null,Object? errorMessage = freezed,Object? initialFirstName = null,Object? initialLastName = null,Object? initialEmail = null,Object? initialGender = freezed,Object? initialDateOfBirth = freezed,Object? initialReferralSource = freezed,Object? initialZipcode = null,}) {
  return _then(_ProfileFormState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ProfileFormMode,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,referralSource: freezed == referralSource ? _self.referralSource : referralSource // ignore: cast_nullable_to_non_nullable
as ReferralSource?,zipcode: null == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,hasChanges: null == hasChanges ? _self.hasChanges : hasChanges // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,initialFirstName: null == initialFirstName ? _self.initialFirstName : initialFirstName // ignore: cast_nullable_to_non_nullable
as String,initialLastName: null == initialLastName ? _self.initialLastName : initialLastName // ignore: cast_nullable_to_non_nullable
as String,initialEmail: null == initialEmail ? _self.initialEmail : initialEmail // ignore: cast_nullable_to_non_nullable
as String,initialGender: freezed == initialGender ? _self.initialGender : initialGender // ignore: cast_nullable_to_non_nullable
as Gender?,initialDateOfBirth: freezed == initialDateOfBirth ? _self.initialDateOfBirth : initialDateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,initialReferralSource: freezed == initialReferralSource ? _self.initialReferralSource : initialReferralSource // ignore: cast_nullable_to_non_nullable
as ReferralSource?,initialZipcode: null == initialZipcode ? _self.initialZipcode : initialZipcode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
