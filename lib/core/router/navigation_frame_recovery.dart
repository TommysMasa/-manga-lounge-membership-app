import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'navigation_diagnostics.dart';

/// A bounded recovery for a foreground iOS navigation whose requested frame
/// never arrives. Normal frames cancel the fallback; there is no polling.
class NavigationFrameRecovery {
  NavigationFrameRecovery({
    SchedulerBinding? binding,
    this.delay = const Duration(milliseconds: 100),
  }) : _binding = binding ?? SchedulerBinding.instance;

  final SchedulerBinding _binding;
  final Duration delay;
  Timer? _timer;
  int _generation = 0;

  void request() {
    _timer?.cancel();
    final generation = ++_generation;
    NavigationDiagnostics.event(
      _binding.framesEnabled ? 'frame.enabled' : 'frame.disabled',
    );
    NavigationDiagnostics.event(
      _binding.hasScheduledFrame ? 'frame.pending' : 'frame.notPending',
    );
    _binding.addPostFrameCallback((_) {
      if (generation == _generation) _timer?.cancel();
    });
    _binding.ensureVisualUpdate();
    _timer = Timer(delay, () {
      if (generation != _generation ||
          _binding.lifecycleState != AppLifecycleState.resumed ||
          _binding.schedulerPhase != SchedulerPhase.idle)
        return;
      NavigationDiagnostics.event('frame.recovery');
      _binding.scheduleWarmUpFrame();
    });
  }

  void dispose() {
    _generation++;
    _timer?.cancel();
  }
}
