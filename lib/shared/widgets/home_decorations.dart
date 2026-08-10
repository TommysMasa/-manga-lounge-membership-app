import 'package:flutter/cupertino.dart';

/// Decorative painters for the home screen cards (organic blobs, dot grids,
/// sparkles, and the lounge-chair illustration). All vector, so they stay
/// crisp at any size and add nothing to app size.

/// Soft grid of small dots (used on the Membership and seats cards).
class DotsGridPainter extends CustomPainter {
  const DotsGridPainter({required this.color, this.dotRadius = 2.2, this.gap = 14});

  final Color color;
  final double dotRadius;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double x = dotRadius; x < size.width; x += gap) {
      for (double y = dotRadius; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotsGridPainter old) =>
      old.color != color || old.dotRadius != dotRadius || old.gap != gap;
}

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

/// Gentle green wave along the bottom of the seats card.
class SeatsWavePainter extends CustomPainter {
  const SeatsWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = const Color(0x1434C759);
    final path = Path()
      ..moveTo(0, h)
      ..quadraticBezierTo(w * 0.35, h * 0.55, w * 0.65, h * 0.8)
      ..quadraticBezierTo(w * 0.85, h * 0.95, w, h * 0.7)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Four-point sparkle, used on the coupon stub.
class SparklePainter extends CustomPainter {
  const SparklePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(w / 2, 0)
      ..quadraticBezierTo(w * 0.58, h * 0.42, w, h / 2)
      ..quadraticBezierTo(w * 0.58, h * 0.58, w / 2, h)
      ..quadraticBezierTo(w * 0.42, h * 0.58, 0, h / 2)
      ..quadraticBezierTo(w * 0.42, h * 0.42, w / 2, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklePainter old) => old.color != color;
}

/// Cozy reading corner: hanging lamp, armchair and a small plant, drawn in
/// light warm tones for the welcome card.
class LoungeCornerPainter extends CustomPainter {
  const LoungeCornerPainter();

  static const _line = Color(0xFFEFC291);
  static const _fill = Color(0xFFFBE8D2);
  static const _accent = Color(0xFFF6D9B7);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = Paint()
      ..color = _line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = _fill;
    final accent = Paint()..color = _accent;

    // Hanging lamp (upper left of the illustration area)
    final lampX = w * 0.30;
    canvas.drawLine(Offset(lampX, 0), Offset(lampX, h * 0.22), stroke);
    final shade = Path()
      ..moveTo(lampX - w * 0.09, h * 0.34)
      ..quadraticBezierTo(lampX, h * 0.16, lampX + w * 0.09, h * 0.34)
      ..close();
    canvas.drawPath(shade, accent);

    // Armchair
    final chairLeft = w * 0.30;
    final chairRight = w * 0.92;
    final seatTop = h * 0.52;
    final chairBottom = h * 0.88;
    // Backrest
    canvas.drawRRect(
      RRect.fromLTRBR(
        chairLeft + w * 0.08,
        h * 0.34,
        chairRight - w * 0.08,
        chairBottom - h * 0.08,
        Radius.circular(w * 0.10),
      ),
      fill,
    );
    // Seat cushion
    canvas.drawRRect(
      RRect.fromLTRBR(
        chairLeft + w * 0.10,
        seatTop + h * 0.10,
        chairRight - w * 0.10,
        chairBottom - h * 0.10,
        Radius.circular(w * 0.06),
      ),
      accent,
    );
    // Armrests
    canvas.drawRRect(
      RRect.fromLTRBR(
        chairLeft,
        seatTop,
        chairLeft + w * 0.14,
        chairBottom,
        Radius.circular(w * 0.07),
      ),
      accent,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        chairRight - w * 0.14,
        seatTop,
        chairRight,
        chairBottom,
        Radius.circular(w * 0.07),
      ),
      accent,
    );
    // Legs
    canvas.drawLine(
      Offset(chairLeft + w * 0.08, chairBottom),
      Offset(chairLeft + w * 0.06, h * 0.97),
      stroke,
    );
    canvas.drawLine(
      Offset(chairRight - w * 0.08, chairBottom),
      Offset(chairRight - w * 0.06, h * 0.97),
      stroke,
    );

    // Plant (bottom right)
    final potX = w * 0.10;
    final potTop = h * 0.80;
    canvas.drawRRect(
      RRect.fromLTRBR(
        potX - w * 0.05,
        potTop,
        potX + w * 0.05,
        h * 0.95,
        Radius.circular(4),
      ),
      accent,
    );
    final leaf = Paint()
      ..color = _line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(potX, potTop), Offset(potX, h * 0.66), leaf);
    canvas.drawLine(Offset(potX, potTop + 4), Offset(potX - w * 0.05, h * 0.70), leaf);
    canvas.drawLine(Offset(potX, potTop + 4), Offset(potX + w * 0.05, h * 0.70), leaf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
