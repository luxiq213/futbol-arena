import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StadiumBackground extends StatelessWidget {
  final Widget child;
  final bool showFieldLines;
  final bool showLiveMatch;
  final bool safeBottom;

  const StadiumBackground({
    super.key,
    required this.child,
    this.showFieldLines = true,
    this.showLiveMatch = false,
    this.safeBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF072116),
            Color(0xFF051810),
            Color(0xFF04120C),
          ],
          stops: [0.0, 0.52, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Top dual stadium floodlight ambient glows
          Positioned(
            top: -90,
            left: -40,
            right: -40,
            height: 290,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.45, -0.85),
                    radius: 1.05,
                    colors: [
                      AppColors.pitchGreen.withValues(alpha: 0.17),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -30,
            right: -30,
            height: 250,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.55, -0.9),
                    radius: 0.95,
                    colors: [
                      AppColors.gold.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Subtle tactical pitch markings watermark
          if (showFieldLines)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _StadiumFieldLinesPainter(),
                ),
              ),
            ),

          // Foreground Content
          SafeArea(bottom: safeBottom, child: child),
        ],
      ),
    );
  }
}

class _StadiumFieldLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final chalk = Paint()
      ..color = Colors.white.withValues(alpha: 0.036)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Subtle alternating turf bands in the top hero area
    final bandPaint = Paint()..color = AppColors.pitchGreen.withValues(alpha: 0.022);
    const bandCount = 6;
    final bandWidth = w / bandCount;
    for (int i = 0; i < bandCount; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(i * bandWidth, 0, bandWidth, h * 0.42),
        bandPaint,
      );
    }

    // Halfway line & center circle
    final centerY = h * 0.48;
    canvas.drawLine(Offset(18, centerY), Offset(w - 18, centerY), chalk);
    canvas.drawCircle(Offset(w / 2, centerY), w * 0.24, chalk);
    canvas.drawCircle(
      Offset(w / 2, centerY),
      3.5,
      Paint()..color = Colors.white.withValues(alpha: 0.06),
    );

    // Subtle upper penalty arc silhouette
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w / 2, 54), width: w * 0.56, height: 108),
      chalk,
    );
  }

  @override
  bool shouldRepaint(covariant _StadiumFieldLinesPainter oldDelegate) => false;
}
