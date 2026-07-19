import 'package:flutter/cupertino.dart';

// Premium palette shared across screens
const Color kPremiumNavy = Color(0xFF06284F);
const Color kPremiumNavyDark = Color(0xFF041B36);
const Color kPremiumGold = Color(0xFFE4C385);
const Color kPremiumAvatarIcon = Color(0xFF042855);
const Color kPremiumBlue = Color(0xFF0F52A6);
const Color kPremiumCardBg = Color(0xFF06254F);

/// Gold-outlined "PREMIUM" pill with a crown, as shown on the
/// membership card hero.
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: kPremiumNavy,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kPremiumGold, width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Crown(size: 16, color: kPremiumGold),
          SizedBox(width: 7),
          Text(
            'PREMIUM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: kPremiumGold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small flat crown glyph (no crown icon exists in the bundled icon fonts)
class Crown extends StatelessWidget {
  const Crown({super.key, required this.size, required this.color});

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
