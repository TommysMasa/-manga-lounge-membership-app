import 'package:flutter/cupertino.dart';

/// Decorative painter for the Membership card (organic blobs). Vector, so
/// it stays crisp at any size.

/// Two soft organic blobs for the Membership card background.
class MembershipBlobsPainter extends CustomPainter {
  const MembershipBlobsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Darker sweep across the top-left.
    final dark = Paint()..color = const Color(0x33203C77);
    final darkPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.72, 0)
      ..quadraticBezierTo(w * 0.5, h * 0.45, w * 0.18, h * 0.52)
      ..quadraticBezierTo(0, h * 0.56, 0, h * 0.4)
      ..close();
    canvas.drawPath(darkPath, dark);

    // Lighter wave hugging the bottom-right.
    final light = Paint()..color = const Color(0x1AFFFFFF);
    final lightPath = Path()
      ..moveTo(w, h * 0.35)
      ..quadraticBezierTo(w * 0.72, h * 0.55, w * 0.62, h)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(lightPath, light);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
