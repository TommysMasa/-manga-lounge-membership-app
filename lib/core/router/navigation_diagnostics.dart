import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Opt-in, local diagnostics. Never include member details or route parameters.
class NavigationDiagnostics {
  static const enabled = bool.fromEnvironment('MEMBER_NAVIGATION_DIAGNOSTICS');
  static final _clock = Stopwatch()..start();
  static int _sequence = 0;

  static void event(String event, {int? tab}) {
    if (!enabled) return;
    debugPrint(
      '[member.navigation] ${++_sequence} ${_clock.elapsedMicroseconds}us $event${tab == null ? '' : ' tab=$tab'}',
    );
  }

  static void afterFrame(String event, {int? tab}) {
    if (!enabled) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      NavigationDiagnostics.event(event, tab: tab);
    });
  }
}
