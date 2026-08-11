import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/push_notification_config.dart';
import '../../../../shared/theme/app_theme.dart';
import '../providers/coupon_providers.dart';

/// Home-screen coupon card: the member's current coupon rendered in full
/// (bold brand-orange), straight on the home screen. No separate wallet
/// screen; the ladder grants at most one active coupon at a time. Renders
/// nothing when there is no coupon.
///
/// A coupon's FIRST appearance gets the Duolingo-style reward pop plus a
/// vibration; once celebrated (persisted per coupon identity), later app
/// opens show the card statically.
class CouponsHomeCard extends ConsumerStatefulWidget {
  const CouponsHomeCard({super.key});

  @override
  ConsumerState<CouponsHomeCard> createState() => _CouponsHomeCardState();
}

class _CouponsHomeCardState extends ConsumerState<CouponsHomeCard>
    with WidgetsBindingObserver {
  static const _celebratedPrefsKey = 'celebratedCouponKey';

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

  StreamSubscription<RemoteMessage>? _pushSubscription;
  SharedPreferences? _prefs;
  String? _celebratedKey;

  /// Coupon identity currently playing (or having played) its pop-in this
  /// session; keeps the animation running across rebuilds after the
  /// celebrated key is persisted.
  String? _animatingKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      setState(() {
        _prefs = prefs;
        _celebratedKey = prefs.getString(_celebratedPrefsKey);
      });
    });
    // A coupon can be granted while the card is already on screen (checkout
    // push arriving in the foreground); reload so it appears immediately.
    _pushSubscription = PushNotificationConfig.foregroundMessages.listen((m) {
      if (m.data['type'] == 'coupon_acquired') {
        ref.invalidate(myCouponProvider);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pushSubscription?.cancel();
    super.dispose();
  }

  // Coupons change while the app is backgrounded (granted at checkout, spent
  // at the register, expired overnight), so refetch on every return to the
  // foreground - including the "tapped the acquisition push" path.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(myCouponProvider);
    }
  }

  String _identityOf(Map<String, dynamic> coupon) =>
      '${coupon['kind']}-${coupon['percent']}-${coupon['lastValidDate']}';

  @override
  Widget build(BuildContext context) {
    final coupon = ref.watch(myCouponProvider).value ?? _debugSample;
    // Wait for prefs before showing: rendering earlier would either replay
    // the pop for an already-celebrated coupon or show a new one statically.
    if (coupon == null || _prefs == null) return const SizedBox.shrink();

    final key = _identityOf(coupon);
    if (key != _celebratedKey && _animatingKey != key) {
      // First time this coupon is ever on screen: celebrate once.
      _animatingKey = key;
      _prefs!.setString(_celebratedPrefsKey, key);
      _celebratedKey = key;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Buzz with the pop, Duolingo-style.
        try {
          await HapticFeedback.vibrate();
        } catch (_) {}
      });
    }

    final card = _buildCard(coupon);
    if (_animatingKey != key) return card;

    // Duolingo-style reward pop: the ticket springs in well past full size,
    // rubber-bands back with a little rotation wobble, and settles.
    return TweenAnimationBuilder<double>(
      key: ValueKey(key),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, t, child) => Opacity(
        opacity: (t * 2).clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: (1 - t) * -0.05,
          child: Transform.scale(scale: 0.5 + 0.5 * t, child: child),
        ),
      ),
      child: card,
    );
  }

  Widget _buildCard(Map<String, dynamic> coupon) {
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
      margin: const EdgeInsets.only(bottom: 16),
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
