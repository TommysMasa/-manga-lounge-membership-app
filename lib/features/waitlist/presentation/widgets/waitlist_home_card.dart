import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../waitlist_format.dart';

/// Home-screen card with live seat availability and the user's waitlist
/// state. Tap opens the waitlist screen (join form or in-line status).
///
/// States, driven by `joinWaitlistAsMember {action: 'status'}`:
///   - seats open  → "N seats open · Walk right in"
///   - at capacity → "Full · N parties waiting · Est. wait X–Y min"
///   - in line     → "#P in line · Est. wait X–Y min"
///   - called      → "Your seats are ready!"
class WaitlistHomeCard extends ConsumerStatefulWidget {
  const WaitlistHomeCard({super.key});

  @override
  ConsumerState<WaitlistHomeCard> createState() => _WaitlistHomeCardState();
}

class _WaitlistHomeCardState extends ConsumerState<WaitlistHomeCard> {
  Map<String, dynamic>? _data;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    try {
      final callable = ref
          .read(functionsProvider)
          .httpsCallable('joinWaitlistAsMember');
      final result = await callable.call<Map<dynamic, dynamic>>({
        'action': 'status',
      });
      if (!mounted) return;
      setState(() => _data = Map<String, dynamic>.from(result.data));
    } catch (_) {
      // Keep the last known state; the next poll retries.
    }
  }

  String? _waitQuote(Map<String, dynamic> m) {
    final lo = m['waitLowMinutes'] as int?;
    final hi = m['waitHighMinutes'] as int?;
    if (lo == null || hi == null) return null;
    if (hi >= 120) return 'over ${lo ~/ 60} hr';
    return '$lo–$hi min';
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;

    final IconData icon;
    final Color color;
    final String title;
    final String subtitle;

    if (d == null) {
      icon = CupertinoIcons.person_2;
      color = AppTheme.textSecondary;
      title = 'Seat availability';
      subtitle = 'Checking…';
    } else if (d['status'] == 'called') {
      final grace = d['graceMinutes'] as int? ?? 10;
      final deadline = checkInDeadline(d, grace);
      icon = CupertinoIcons.bell_fill;
      color = AppTheme.primaryOrange;
      title = 'Your seats are ready! 🎉';
      subtitle = deadline != null
          ? 'Check in at the counter by $deadline'
          : 'Check in at the counter within $grace min';
    } else if (d['status'] == 'waiting') {
      final position = d['position'] as int?;
      final quote = _waitQuote(d);
      icon = CupertinoIcons.clock_fill;
      color = AppTheme.primaryBlue;
      title = position != null ? '#$position in line' : 'On the waitlist';
      subtitle = quote != null
          ? 'Estimated wait: $quote'
          : 'Waiting for seats…';
    } else {
      // Not in line: show the room.
      final seatsFree = d['seatsFree'] as int?;
      final groups = d['groupsWaiting'] as int? ?? 0;
      final quote = _waitQuote(d);
      if (d['noWait'] == true ||
          (seatsFree != null && seatsFree > 0 && groups == 0)) {
        icon = CupertinoIcons.checkmark_circle_fill;
        color = AppTheme.successColor;
        title = seatsFree != null ? '$seatsFree seats open' : 'Seats open';
        subtitle = 'Walk right in, no wait';
      } else {
        icon = CupertinoIcons.person_2_fill;
        color = AppTheme.primaryOrange;
        title = 'Lounge is full';
        subtitle = [
          if (groups > 0)
            '$groups ${groups == 1 ? 'party' : 'parties'} waiting',
          if (quote != null) 'est. $quote',
          'tap to join',
        ].join(' · ');
      }
    }

    return GestureDetector(
      onTap: () => const WaitlistJoinRoute().push<void>(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_forward,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
