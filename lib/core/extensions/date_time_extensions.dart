import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  /// Formats as hours and minutes (e.g. "14:30")
  String toHHmm() => DateFormat('HH:mm').format(this);
}
