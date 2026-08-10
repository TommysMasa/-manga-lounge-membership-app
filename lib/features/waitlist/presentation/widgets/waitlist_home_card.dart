import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../waitlist_format.dart';

/// Chatbot-style floating seat/waitlist button for the home screen.
///
/// Collapsed: a round chair button with a live seat-count badge.
/// Tapped: a small bubble pops up with the current state; tapping the
/// bubble opens the waitlist screen. Auto-opens when the user is on the
/// waitlist or called.
class WaitlistHomeCard extends ConsumerStatefulWidget {
  const WaitlistHomeCard({super.key});

  @override
  ConsumerState<WaitlistHomeCard> createState() => _WaitlistHomeCardState();
}

class _WaitlistHomeCardState extends ConsumerState<WaitlistHomeCard> {
  Map<String, dynamic>? _data;
  Timer? _timer;
  bool _open = false;
  bool _autoOpened = false;

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
      setState(() {
        _data = Map<String, dynamic>.from(result.data);
        // Pop the bubble open once when the user is in line or called.
        final s = _data?['status'];
        if (!_autoOpened && (s == 'called' || s == 'waiting')) {
          _open = true;
          _autoOpened = true;
        }
      });
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
    final status = d?['status'];
    final seatsFree = d?['seatsFree'] as int?;
    final groups = d?['groupsWaiting'] as int? ?? 0;
    final walkIn =
        d?['walkIn'] == true || (seatsFree != null && seatsFree >= 10);
    final called = status == 'called';
    final waiting = status == 'waiting';

    final String title;
    final String subtitle;
    if (called) {
      final grace = d?['graceMinutes'] as int? ?? 10;
      final deadline = d == null ? null : checkInDeadline(d, grace);
      title = 'Your seats are ready! \u{1F389}';
      subtitle = deadline != null
          ? 'Check in at the counter by $deadline'
          : 'Check in at the counter within $grace min';
    } else if (waiting) {
      final position = d?['position'] as int?;
      final quote = d == null ? null : _waitQuote(d);
      title = position != null ? '#$position in line' : 'On the waitlist';
      subtitle = quote != null
          ? 'Estimated wait: $quote'
          : 'Waiting for seats…';
    } else if (d == null || seatsFree == null) {
      title = 'Seats';
      subtitle = 'Checking availability…';
    } else if (seatsFree == 0 || groups > 0) {
      title = 'Full right now';
      subtitle = 'Tap to join the waitlist';
    } else if (walkIn) {
      title = 'Seats available now';
      subtitle = '$seatsFree open, walk right in';
    } else {
      title = 'Filling up';
      subtitle = '$seatsFree seats left, waitlist is open';
    }

    final accent = called ? AppTheme.primaryOrange : AppTheme.primaryBlue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bubble pops out of the button (scale + fade from bottom right)
        IgnorePointer(
          ignoring: !_open,
          child: AnimatedOpacity(
            opacity: _open ? 1 : 0,
            duration: const Duration(milliseconds: 160),
            child: AnimatedScale(
              scale: _open ? 1 : 0.5,
              alignment: Alignment.bottomLeft,
              duration: Duration(milliseconds: _open ? 260 : 160),
              curve: _open ? Curves.easeOutBack : Curves.easeIn,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => const WaitlistJoinRoute().push<void>(context),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withValues(alpha: 0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: called ? accent : AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        CupertinoIcons.chevron_forward,
                        color: Color(0xFFBBBBBB),
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _open = !_open),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _open ? accent : CupertinoColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _open
                        ? const Color(0x00000000)
                        : const Color(0xFFE5E5E5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                // Spins half a turn while the icon crossfades: the
                // chatbot-style "twirl open"
                child: AnimatedRotation(
                  turns: _open ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: _open
                        ? const Icon(
                            CupertinoIcons.xmark,
                            key: ValueKey('close'),
                            color: CupertinoColors.white,
                            size: 22,
                          )
                        : Icon(
                            Icons.chair,
                            key: const ValueKey('chair'),
                            color: accent,
                            size: 26,
                          ),
                  ),
                ),
              ),
              // Live seat-count badge, peeking while collapsed
              if (seatsFree != null || called)
                Positioned(
                  top: -4,
                  right: -6,
                  child: AnimatedScale(
                    scale: _open ? 0 : 1,
                    duration: const Duration(milliseconds: 180),
                    curve: _open ? Curves.easeIn : Curves.easeOutBack,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: called
                            ? AppTheme.primaryOrange
                            : const Color(0xFF3E5C96),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppTheme.backgroundColor,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        called ? '!' : '$seatsFree',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
