/// Shared formatting for waitlist payloads from `joinWaitlistAsMember`.
library;

/// Local check-in deadline ("3:45 PM") from calledAt + grace, or null.
String? checkInDeadline(Map<String, dynamic> entry, int graceMinutes) {
  final calledAtIso = entry['calledAt'] as String?;
  if (calledAtIso == null) return null;
  final calledAt = DateTime.tryParse(calledAtIso);
  if (calledAt == null) return null;
  final deadline = calledAt.add(Duration(minutes: graceMinutes)).toLocal();
  final hour = deadline.hour % 12 == 0 ? 12 : deadline.hour % 12;
  final minute = deadline.minute.toString().padLeft(2, '0');
  final period = deadline.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
