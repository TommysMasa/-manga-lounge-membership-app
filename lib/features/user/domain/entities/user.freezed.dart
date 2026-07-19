// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get uid; String get firstName; String get lastName; String get gender; DateTime get dateOfBirth; String? get referralSource; String? get zipcode;@UserStatusConverter() UserStatus get status; DateTime get createdAt; DateTime? get updatedAt;@TimestampConverter() DateTime? get lastEntryTime;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.referralSource, referralSource) || other.referralSource == referralSource)&&(identical(other.zipcode, zipcode) || other.zipcode == zipcode)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastEntryTime, lastEntryTime) || other.lastEntryTime == lastEntryTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,firstName,lastName,gender,dateOfBirth,referralSource,zipcode,status,createdAt,updatedAt,lastEntryTime);

@override
String toString() {
  return 'User(uid: $uid, firstName: $firstName, lastName: $lastName, gender: $gender, dateOfBirth: $dateOfBirth, referralSource: $referralSource, zipcode: $zipcode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, lastEntryTime: $lastEntryTime)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String uid, String firstName, String lastName, String gender, DateTime dateOfBirth, String? referralSource, String? zipcode,@UserStatusConverter() UserStatus status, DateTime createdAt, DateTime? updatedAt,@TimestampConverter() DateTime? lastEntryTime
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? firstName = null,Object? lastName = null,Object? gender = null,Object? dateOfBirth = null,Object? referralSource = freezed,Object? zipcode = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = freezed,Object? lastEntryTime = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,referralSource: freezed == referralSource ? _self.referralSource : referralSource // ignore: cast_nullable_to_non_nullable
as String?,zipcode: freezed == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastEntryTime: freezed == lastEntryTime ? _self.lastEntryTime : lastEntryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String firstName,  String lastName,  String gender,  DateTime dateOfBirth,  String? referralSource,  String? zipcode, @UserStatusConverter()  UserStatus status,  DateTime createdAt,  DateTime? updatedAt, @TimestampConverter()  DateTime? lastEntryTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.uid,_that.firstName,_that.lastName,_that.gender,_that.dateOfBirth,_that.referralSource,_that.zipcode,_that.status,_that.createdAt,_that.updatedAt,_that.lastEntryTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String firstName,  String lastName,  String gender,  DateTime dateOfBirth,  String? referralSource,  String? zipcode, @UserStatusConverter()  UserStatus status,  DateTime createdAt,  DateTime? updatedAt, @TimestampConverter()  DateTime? lastEntryTime)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.uid,_that.firstName,_that.lastName,_that.gender,_that.dateOfBirth,_that.referralSource,_that.zipcode,_that.status,_that.createdAt,_that.updatedAt,_that.lastEntryTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String firstName,  String lastName,  String gender,  DateTime dateOfBirth,  String? referralSource,  String? zipcode, @UserStatusConverter()  UserStatus status,  DateTime createdAt,  DateTime? updatedAt, @TimestampConverter()  DateTime? lastEntryTime)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.uid,_that.firstName,_that.lastName,_that.gender,_that.dateOfBirth,_that.referralSource,_that.zipcode,_that.status,_that.createdAt,_that.updatedAt,_that.lastEntryTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User extends User {
  const _User({required this.uid, required this.firstName, required this.lastName, required this.gender, required this.dateOfBirth, this.referralSource, this.zipcode, @UserStatusConverter() this.status = UserStatus.checkedOut, required this.createdAt, this.updatedAt, @TimestampConverter() this.lastEntryTime}): super._();
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String uid;
@override final  String firstName;
@override final  String lastName;
@override final  String gender;
@override final  DateTime dateOfBirth;
@override final  String? referralSource;
@override final  String? zipcode;
@override@JsonKey()@UserStatusConverter() final  UserStatus status;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override@TimestampConverter() final  DateTime? lastEntryTime;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.referralSource, referralSource) || other.referralSource == referralSource)&&(identical(other.zipcode, zipcode) || other.zipcode == zipcode)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastEntryTime, lastEntryTime) || other.lastEntryTime == lastEntryTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,firstName,lastName,gender,dateOfBirth,referralSource,zipcode,status,createdAt,updatedAt,lastEntryTime);

@override
String toString() {
  return 'User(uid: $uid, firstName: $firstName, lastName: $lastName, gender: $gender, dateOfBirth: $dateOfBirth, referralSource: $referralSource, zipcode: $zipcode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, lastEntryTime: $lastEntryTime)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String uid, String firstName, String lastName, String gender, DateTime dateOfBirth, String? referralSource, String? zipcode,@UserStatusConverter() UserStatus status, DateTime createdAt, DateTime? updatedAt,@TimestampConverter() DateTime? lastEntryTime
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? firstName = null,Object? lastName = null,Object? gender = null,Object? dateOfBirth = null,Object? referralSource = freezed,Object? zipcode = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = freezed,Object? lastEntryTime = freezed,}) {
  return _then(_User(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,referralSource: freezed == referralSource ? _self.referralSource : referralSource // ignore: cast_nullable_to_non_nullable
as String?,zipcode: freezed == zipcode ? _self.zipcode : zipcode // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastEntryTime: freezed == lastEntryTime ? _self.lastEntryTime : lastEntryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
