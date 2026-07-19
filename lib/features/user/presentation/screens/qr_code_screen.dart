import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/extensions/date_time_extensions.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../../domain/entities/user.dart';

// Premium card palette
const Color _premiumNavy = Color(0xFF16305A);
const Color _premiumNavyDark = Color(0xFF0B1B38);
const Color _premiumGold = Color(0xFFE8C15C);
const Color _premiumGoldDark = Color(0xFFB8860B);
const Color _premiumLine = Color(0xFF3E6EA8);

/// Screen displaying user's QR code for check-in/check-out
class QRCodeScreen extends ConsumerWidget {
  const QRCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider);
    final isPro = ref.watch(isProProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.backgroundColor,
        border: null,
        middle: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Manga Lounge',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              isPro ? 'Premium Membership Card' : 'Membership Card',
              style: TextStyle(
                fontSize: 12,
                color: isPro ? AppTheme.primaryBlue : AppTheme.textSecondary,
                fontWeight: isPro ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
        ),
      ),
      child: userAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, _) => Center(
          child: Text(error is Failure ? error.message : '$error'),
        ),
        data: (user) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isPro)
                  _PremiumMemberCard(user: user)
                else
                  _StandardMemberCard(user: user),

                const SizedBox(height: 16),

                _QrCard(user: user, isPro: isPro),

                const SizedBox(height: 16),

                _StatusCard(user: user, isPro: isPro),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// White member info card for non-subscribers (original design)
class _StandardMemberCard extends StatelessWidget {
  const _StandardMemberCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: CupertinoColors.systemGrey5,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              size: 48,
              color: CupertinoColors.systemGrey2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${user.fullName}\'s',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Membership Card',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Navy + gold hero card for Premium (subscribed) members
class _PremiumMemberCard extends StatelessWidget {
  const _PremiumMemberCard({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_premiumNavy, _premiumNavyDark],
        ),
        boxShadow: [
          BoxShadow(
            color: _premiumNavyDark.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _HalftoneDotsPainter()),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: _PremiumBadge(),
                  ),
                  const SizedBox(height: 8),
                  // Gold avatar
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_premiumGold, _premiumGoldDark],
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      size: 50,
                      color: _premiumNavyDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${user.fullName}\'s',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Premium Membership Card',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _premiumGold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Divider with center diamond
                  Row(
                    children: [
                      const Expanded(
                        child: SizedBox(
                          height: 1,
                          child: ColoredBox(color: _premiumLine),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Transform.rotate(
                          angle: 0.785398, // 45 degrees
                          child: const SizedBox(
                            width: 6,
                            height: 6,
                            child: ColoredBox(color: _premiumLine),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: SizedBox(
                          height: 1,
                          child: ColoredBox(color: _premiumLine),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: _PremiumFeature(
                          icon: Icons.local_drink_outlined,
                          label: 'Unlimited\nDrinks',
                        ),
                      ),
                      _FeatureDivider(),
                      Expanded(
                        child: _PremiumFeature(
                          icon: Icons.menu_book_outlined,
                          label: 'Priority\nSeating',
                        ),
                      ),
                      _FeatureDivider(),
                      Expanded(
                        child: _PremiumFeature(
                          icon: CupertinoIcons.star,
                          label: 'Exclusive\nEvents',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _premiumGold, width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Crown(size: 16, color: _premiumGold),
          SizedBox(width: 7),
          Text(
            'PREMIUM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: _premiumGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  const _PremiumFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: CupertinoColors.white),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            height: 1.25,
            color: CupertinoColors.white,
          ),
        ),
      ],
    );
  }
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 34,
      color: CupertinoColors.white.withValues(alpha: 0.25),
    );
  }
}

/// QR code card; premium members get a blue-framed QR with a center crown
/// and a "Premium Access" caption.
class _QrCard extends StatelessWidget {
  const _QrCard({required this.user, required this.isPro});

  final User user;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final qr = QrImageView(
      data: user.uid,
      version: QrVersions.auto,
      size: isPro ? 230 : 250,
      backgroundColor: CupertinoColors.white,
      // H tolerates the center crown overlay for premium
      errorCorrectionLevel: QrErrorCorrectLevel.H,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (isPro)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryBlue, width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  qr,
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const _Crown(size: 30, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: qr,
            ),
          if (isPro) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 22, height: 1, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  '\u2726 Premium Access \u2726',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 22, height: 1, color: AppTheme.primaryBlue),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Status / entry time card. Premium members additionally see the crown
/// status and their "Member Since" date.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.user, required this.isPro});

  final User user;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final checkStatus = user.isCheckedIn ? 'Checked In' : 'Checked Out';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                CupertinoIcons.person_2,
                color: AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Status:',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
              const Spacer(),
              if (isPro)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Crown(size: 18, color: AppTheme.primaryBlue),
                        SizedBox(width: 6),
                        Text(
                          'Premium Member',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      checkStatus,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  checkStatus,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 0.5, color: CupertinoColors.separator),
          const SizedBox(height: 16),
          // Entry Time
          Row(
            children: [
              const Icon(
                CupertinoIcons.time,
                color: AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Entry Time:',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
              const Spacer(),
              Text(
                user.activeEntryTime?.toHHmm() ?? '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (isPro) ...[
            const SizedBox(height: 16),
            Container(height: 0.5, color: CupertinoColors.separator),
            const SizedBox(height: 16),
            // Member Since
            Row(
              children: [
                const Icon(
                  CupertinoIcons.calendar,
                  color: AppTheme.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Member Since:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(user.createdAt),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

/// Small flat crown glyph (no crown icon exists in the bundled icon fonts)
class _Crown extends StatelessWidget {
  const _Crown({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.78),
      painter: _CrownPainter(color: color),
    );
  }
}

class _CrownPainter extends CustomPainter {
  const _CrownPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = color;

    final body = Path()
      ..moveTo(w * 0.10, h * 0.74)
      ..lineTo(w * 0.02, h * 0.24)
      ..lineTo(w * 0.30, h * 0.44)
      ..lineTo(w * 0.50, h * 0.06)
      ..lineTo(w * 0.70, h * 0.44)
      ..lineTo(w * 0.98, h * 0.24)
      ..lineTo(w * 0.90, h * 0.74)
      ..close();
    canvas.drawPath(body, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.82, w * 0.80, h * 0.14),
        Radius.circular(h * 0.07),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CrownPainter oldDelegate) => oldDelegate.color != color;
}

/// Faint halftone dot texture in the top-right and bottom-left corners
/// of the premium card.
class _HalftoneDotsPainter extends CustomPainter {
  const _HalftoneDotsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = CupertinoColors.white.withValues(alpha: 0.07);
    const spacing = 13.0;
    const reach = 150.0;

    final corners = [Offset(size.width, 0), Offset(0, size.height)];
    for (final corner in corners) {
      for (double x = 0; x <= size.width; x += spacing) {
        for (double y = 0; y <= size.height; y += spacing) {
          final d = (Offset(x, y) - corner).distance;
          if (d > reach) continue;
          final r = 2.6 * (1 - d / reach);
          if (r <= 0.2) continue;
          canvas.drawCircle(Offset(x, y), r, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HalftoneDotsPainter oldDelegate) => false;
}
