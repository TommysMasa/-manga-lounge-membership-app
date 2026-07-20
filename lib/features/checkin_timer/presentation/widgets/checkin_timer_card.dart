import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_theme.dart';
import '../providers/checkin_timer_provider.dart';

/// Home screen card showing the remaining visit timer with a cancel button.
///
/// Renders nothing when no timer is active.
class CheckInTimerCard extends ConsumerStatefulWidget {
  const CheckInTimerCard({super.key});

  @override
  ConsumerState<CheckInTimerCard> createState() => _CheckInTimerCardState();
}

class _CheckInTimerCardState extends ConsumerState<CheckInTimerCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Refresh the countdown text and clear the state once the timer fires.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.read(checkInTimerProvider.notifier).clearIfExpired();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _remainingLabel(DateTime end) {
    final remaining = end.difference(DateTime.now());
    // Round up so the label never shows less time than actually remains.
    final minutes = (remaining.inSeconds / 60).ceil().clamp(1, 24 * 60);
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m remaining';
    if (h > 0) return '${h}h remaining';
    return '${m}m remaining';
  }

  Future<void> _cancelTimer() async {
    await ref.read(checkInTimerProvider.notifier).cancel();
    if (mounted) {
      AppTheme.showNotification(context, message: 'Timer cancelled.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final end = ref.watch(checkInTimerProvider);
    if (end == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              CupertinoIcons.timer,
              color: AppTheme.primaryBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Timer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _remainingLabel(end),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _cancelTimer,
            child: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
