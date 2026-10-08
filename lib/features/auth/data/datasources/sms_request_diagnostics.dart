import 'dart:developer' as developer;

/// Process-local bounded diagnostics. No phone, UID, IP, OTP or Firebase payload.
/// These count app SDK calls, not internal SDK HTTP requests or delivered SMS.
class SmsRequestDiagnostics {
  static int _sequence = 0;
  static final List<Map<String, Object>> _events = [];
  static List<Map<String, Object>> get events => List.unmodifiable(
    _events.map((event) => Map<String, Object>.unmodifiable(event)),
  );

  /// Only explicit provider wording is classified; never retain the message.
  /// A hint is not proof of the internal anti-abuse decision or reset time.
  static String restrictionHint(String? message) {
    final normalized = message?.toLowerCase() ?? '';
    if (normalized.contains('requests from this device') &&
        normalized.contains('unusual activity')) {
      return 'device-unusual-activity';
    }
    if (normalized.contains('too many sms messages') &&
        normalized.contains('phone number')) {
      return 'phone-sms-limit';
    }
    return 'unspecified';
  }

  static int begin() {
    final request = ++_sequence;
    record(request, 'requested');
    return request;
  }

  static void record(
    int request,
    String event, {
    int? elapsedMs,
    String? code,
    String? providerMessage,
  }) {
    final safeCode = code == null
        ? null
        : (RegExp(r'^[a-z0-9-]{1,64}$').hasMatch(code)
              ? code
              : 'unknown-error');
    final row = <String, Object>{
      'request': request,
      'event': event,
      'atUtc': DateTime.now().toUtc().toIso8601String(),
      if (elapsedMs != null) 'elapsedMs': elapsedMs,
      if (safeCode != null) 'code': safeCode,
      if (safeCode == 'too-many-requests')
        'providerHint': restrictionHint(providerMessage),
    };
    _events.add(row);
    if (_events.length > 100) _events.removeAt(0);
    developer.log(row.toString(), name: 'member.sms');
  }
}
