import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:manga_lounge/core/router/navigation_frame_recovery.dart';

class TestScheduler extends Mock implements SchedulerBinding {}

void main() {
  late TestScheduler binding;
  late NavigationFrameRecovery recovery;
  late FrameCallback delivered;
  setUp(() {
    binding = TestScheduler();
    when(() => binding.framesEnabled).thenReturn(true);
    when(() => binding.hasScheduledFrame).thenReturn(true);
    when(() => binding.lifecycleState).thenReturn(AppLifecycleState.resumed);
    when(() => binding.schedulerPhase).thenReturn(SchedulerPhase.idle);
    when(() => binding.addPostFrameCallback(any())).thenAnswer((invocation) {
      delivered = invocation.positionalArguments.first as FrameCallback;
    });
    recovery = NavigationFrameRecovery(
      binding: binding,
      delay: const Duration(milliseconds: 1),
    );
  });
  setUpAll(() => registerFallbackValue((Duration _) {}));
  tearDown(() => recovery.dispose());
  test('missing foreground frame gets one recovery', () async {
    recovery.request();
    await Future<void>.delayed(const Duration(milliseconds: 15));
    verify(() => binding.scheduleWarmUpFrame()).called(1);
    await Future<void>.delayed(const Duration(milliseconds: 15));
    verifyNever(() => binding.scheduleWarmUpFrame());
  });
  test('normal frame cancels recovery', () async {
    recovery.request();
    delivered(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 15));
    verifyNever(() => binding.scheduleWarmUpFrame());
  });
  test('background app is never forced to render', () async {
    when(() => binding.lifecycleState).thenReturn(AppLifecycleState.paused);
    recovery.request();
    await Future<void>.delayed(const Duration(milliseconds: 15));
    verifyNever(() => binding.scheduleWarmUpFrame());
  });
  test('repeated taps replace the pending recovery', () async {
    recovery.request();
    recovery.request();
    recovery.request();
    await Future<void>.delayed(const Duration(milliseconds: 15));
    verify(() => binding.scheduleWarmUpFrame()).called(1);
  });
}
