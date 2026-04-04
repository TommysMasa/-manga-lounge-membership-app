/// Utility functions for formatting DateTime objects
class DateTimeFormatter {
  /// Format entry time to "HH:MM AM/PM" format
  ///
  /// Examples:
  /// - DateTime(2026, 3, 2, 19, 5, 53) → "07:05 PM"
  /// - DateTime(2026, 3, 2, 9, 30, 0) → "09:30 AM"
  /// - DateTime(2026, 3, 2, 0, 15, 0) → "12:15 AM"
  static String formatEntryTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';

    // Convert 24-hour format to 12-hour format
    final displayHour = hour > 12
        ? hour - 12
        : (hour == 0 ? 12 : hour);

    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  /// Get entry time display string based on status and lastEntryTime
  ///
  /// Returns:
  /// - If checked_in and lastEntryTime exists: formatted time (e.g., "07:05 PM")
  /// - Otherwise: "-"
  static String getEntryTimeDisplay({
    required String status,
    DateTime? lastEntryTime,
  }) {
    if (status == 'checked_in' && lastEntryTime != null) {
      return formatEntryTime(lastEntryTime);
    }
    return '-';
  }
}
