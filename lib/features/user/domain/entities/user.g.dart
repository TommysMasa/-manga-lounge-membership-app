// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  uid: json['uid'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  gender: json['gender'] as String,
  dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
  referralSource: json['referralSource'] as String?,
  status: json['status'] == null
      ? UserStatus.checkedOut
      : const UserStatusConverter().fromJson(json['status'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  lastEntryTime: _$JsonConverterFromJson<Object, DateTime>(
    json['lastEntryTime'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'uid': instance.uid,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'gender': instance.gender,
  'dateOfBirth': instance.dateOfBirth.toIso8601String(),
  'referralSource': instance.referralSource,
  'status': const UserStatusConverter().toJson(instance.status),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'lastEntryTime': _$JsonConverterToJson<Object, DateTime>(
    instance.lastEntryTime,
    const TimestampConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
