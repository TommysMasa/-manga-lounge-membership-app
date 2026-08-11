import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';

/// Duolingo-style full-screen loader: the logo bobs gently on the brand
/// background while the first home data loads, then the page appears all at
/// once. Shown instead of drip-feeding cards in as their fetches resolve.
class BrandedLoadingScreen extends StatefulWidget {
  const BrandedLoadingScreen({super.key});

  @override
  State<BrandedLoadingScreen> createState() => _BrandedLoadingScreenState();
}

class _BrandedLoadingScreenState extends State<BrandedLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // One full sine per cycle: rise, hang, settle - a soft bob
              // with a hint of squash-and-stretch at the bottom.
              final t = math.sin(_controller.value * 2 * math.pi);
              return Transform.translate(
                offset: Offset(0, -6 * t),
                child: Transform.scale(
                  scaleY: 1 - 0.02 * t,
                  scaleX: 1 + 0.02 * t,
                  child: child,
                ),
              );
            },
            child: Image.asset(
              'assets/images/logo_1.png',
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 36),
          const CupertinoActivityIndicator(radius: 12),
        ],
      ),
    );
  }
}
