import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Converts between DateTime and Firestore Timestamp/ISO8601 string.
///
/// Firestore returns native Timestamp objects when fields are written
/// via admin SDKs, but ISO8601 strings when written via toJson().
/// This converter handles both formats on read.
class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    throw FormatException('Cannot convert $json to DateTime');
  }

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
