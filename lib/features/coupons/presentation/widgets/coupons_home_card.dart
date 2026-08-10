import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';

/// Home-screen coupon card: the member's current coupon rendered in full
/// (bold brand-orange), straight on the home screen. No separate wallet
/// screen; the ladder grants at most one active coupon at a time. Renders
/// nothing when there is no coupon.
class CouponsHomeCard extends ConsumerStatefulWidget {
  const CouponsHomeCard({super.key});

  @override
  ConsumerState<CouponsHomeCard> createState() => _CouponsHomeCardState();
}

class _CouponsHomeCardState extends ConsumerState<CouponsHomeCard> {
  /// Debug builds only: sample coupon so the design can be previewed on the
  /// simulator even when the signed-in account has none. Never shows in
  /// release/TestFlight builds.
  static final Map<String, dynamic>? _debugSample = kDebugMode
      ? {
          'kind': 'percent',
          'percent': 30,
          'state': 'come-back',
          'lastValidDate': 'Aug 15',
          'daysLeft': 3,
        }
      : null;

  Map<String, dynamic>? _coupon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final callable = ref
          .read(functionsProvider)
          .httpsCallable(
            'getMyCoupons',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 10)),
          );
      final result = await callable.call<Map<dynamic, dynamic>>({});
      if (!mounted) return;
      final list = (result.data['coupons'] as List<dynamic>? ?? [])
          .map((c) => Map<String, dynamic>.from(c as Map))
          .toList();
      setState(() => _coupon = list.isEmpty ? _debugSample : list.first);
    } catch (_) {
      // No coupon shown on failure; the card simply stays hidden.
      if (mounted && _debugSample != null) {
        setState(() => _coupon = _debugSample);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final coupon = _coupon;
    if (coupon == null) return const SizedBox.shrink();

    final isFree = coupon['kind'] == 'free_return';
    final percent = coupon['percent'] as int? ?? 0;
    final useToday = coupon['state'] == 'use-today';
    final daysLeft = coupon['daysLeft'] as int? ?? 0;

    final String pillLabel;
    if (useToday) {
      pillLabel = 'Use today';
    } else if (daysLeft <= 0) {
      pillLabel = 'Last day!';
    } else if (daysLeft == 1) {
      pillLabel = '1 day left';
    } else {
      pillLabel = '$daysLeft days left';
    }

    final title = useToday ? 'This visit' : 'Your next visit';
    const sub = '(applied automatically)';

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ticket stub
                  Container(
                    width: 92,
                    color: AppTheme.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isFree ? 'FREE' : '$percent%',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: CupertinoColors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isFree ? 'VISIT' : 'OFF',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFE3C4),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Perforation
                  const SizedBox(
                    width: 2,
                    child: CustomPaint(
                      painter: _PerforationPainter(),
                      size: Size(2, double.infinity),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            sub,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              // Red once it's about to expire.
                              color: !useToday && daysLeft <= 1
                                  ? const Color(0xFFFDE2E2)
                                  : const Color(0xFFFFF1E0),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              pillLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: !useToday && daysLeft <= 1
                                    ? const Color(0xFFB91C1C)
                                    : const Color(0xFF9A5A00),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Punch holes over the perforation line (clipped to half circles)
            const Positioned(left: 82, top: -11, child: _PunchHole()),
            const Positioned(left: 82, bottom: -11, child: _PunchHole()),
          ],
        ),
      ),
    );
  }
}

class _PunchHole extends StatelessWidget {
  const _PunchHole();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Vertical dashed "tear here" line between the stub and the body.
class _PerforationPainter extends CustomPainter {
  const _PerforationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5C9A8)
      ..strokeWidth = 2;
    const dash = 5.0;
    const gap = 4.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(1, y), Offset(1, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
