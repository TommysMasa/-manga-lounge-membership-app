import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  /// Formats as hours and minutes in 12-hour format with AM/PM (e.g. "2:30 PM")
  String toHHmm() {
    final hour = this.hour;
    final minute = this.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';

    // Convert 24-hour format to 12-hour format
    final displayHour = hour > 12
        ? hour - 12
        : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }
}
