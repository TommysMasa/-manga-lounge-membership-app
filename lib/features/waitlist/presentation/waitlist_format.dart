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

/// Snapshot of the last `waitlist_called` push tap. The waitlist screen
/// renders the called view from this instantly, then the status poll
/// confirms (or corrects) it. Without the hint, a slow first fetch briefly
/// shows the join form on the way to "your seats are ready".
class WaitlistPushHint {
  static Map<String, dynamic>? _data;
  static DateTime? _at;

  static void set(Map<String, dynamic> data) {
    _data = data;
    _at = DateTime.now();
  }

  /// One-shot: returns an entry-payload-shaped map when a fresh (<10 min)
  /// hint exists, else null.
  static Map<String, dynamic>? take() {
    final data = _data;
    final at = _at;
    _data = null;
    _at = null;
    if (data == null || at == null) return null;
    if (DateTime.now().difference(at) > const Duration(minutes: 10)) {
      return null;
    }
    return {
      'status': 'called',
      'calledAt': data['calledAt'],
      'graceMinutes': int.tryParse('${data['graceMinutes']}') ?? 10,
      'partySize': int.tryParse('${data['partySize']}'),
    };
  }
}
