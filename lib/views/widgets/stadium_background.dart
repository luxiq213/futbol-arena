import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StadiumBackground extends StatefulWidget {
  final Widget child;
  final bool showFieldLines;

  const StadiumBackground({
    super.key,
    required this.child,
    this.showFieldLines = true,
  });

  @override
  State<StadiumBackground> createState() => _StadiumBackgroundState();
}

class _StadiumBackgroundState extends State<StadiumBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF061A12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Football Pitch Lawn Mowing Bands & Micro-Turf Texture
          Positioned.fill(
            child: CustomPaint(
              painter: _FootballPitchBasePainter(),
            ),
          ),

          // 2. Realistic Tactical Pitch Markings & Stadium Floodlight Beams
          if (widget.showFieldLines)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _TacticalFieldLinesPainter(
                      pulseProgress: _pulseController.value,
                    ),
                  );
                },
              ),
            ),

          // 3. Balanced Vignette Overlay for UI Contrast while preserving pitch visibility
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF04120C).withValues(alpha: 0.42),
                      const Color(0xFF061B13).withValues(alpha: 0.18),
                      const Color(0xFF05160F).withValues(alpha: 0.40),
                      const Color(0xFF030D09).withValues(alpha: 0.68),
                    ],
                    stops: const [0.0, 0.35, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 4. Foreground Content
          SafeArea(child: widget.child),
        ],
      ),
    );
  }
}

/// Paints the alternating cut turf lawn pattern of an elite football stadium pitch
class _FootballPitchBasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Rich nocturnal stadium grass stripes
    const darkStripe = Color(0xFF072217);
    const lightStripe = Color(0xFF0B2C1E);

    const stripeHeight = 58.0;
    final count = (height / stripeHeight).ceil() + 1;

    for (int i = 0; i < count; i++) {
      final y = i * stripeHeight;
      final paint = Paint()
        ..color = (i % 2 == 0) ? lightStripe : darkStripe
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, y, width, stripeHeight), paint);
    }

    // Subtle vertical grass mowing sheen lines
    final sheenPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.025)
      ..strokeWidth = 1.0;
    for (double x = 24; x < width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), sheenPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints authentic stadium chalk lines (Touchline, penalty box, 6-yard box, center circle, corner arcs, floodlights)
class _TacticalFieldLinesPainter extends CustomPainter {
  final double pulseProgress;

  _TacticalFieldLinesPainter({required this.pulseProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final lineAlpha = 0.13 + pulseProgress * 0.04;
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: lineAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final glowPaint = Paint()
      ..color = AppColors.pitchGreen.withValues(alpha: 0.06 + pulseProgress * 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final spotPaint = Paint()
      ..color = Colors.white.withValues(alpha: lineAlpha * 1.4)
      ..style = PaintingStyle.fill;

    // Outer pitch boundary (touchlines & goal lines)
    const marginX = 10.0;
    const marginY = 8.0;
    final pitchWidth = width - marginX * 2;
    final pitchHeight = height - marginY * 2;
    final pitchRect = Rect.fromLTWH(marginX, marginY, pitchWidth, pitchHeight);
    canvas.drawRect(pitchRect, linePaint);

    // Halfway line & Center circle
    final centerY = height * 0.52;
    final centerCircleRadius = width * 0.24;
    final center = Offset(width * 0.5, centerY);

    canvas.drawLine(Offset(marginX, centerY), Offset(width - marginX, centerY), linePaint);
    canvas.drawCircle(center, centerCircleRadius, glowPaint);
    canvas.drawCircle(center, centerCircleRadius, linePaint);
    canvas.drawCircle(center, 3.5, spotPaint);

    // Top 18-yard Penalty Box & 6-yard Goal Box
    final boxWidth = pitchWidth * 0.62;
    final boxHeight = pitchHeight * 0.15;
    final boxLeft = marginX + (pitchWidth - boxWidth) / 2;
    canvas.drawRect(Rect.fromLTWH(boxLeft, marginY, boxWidth, boxHeight), linePaint);

    final goalBoxWidth = pitchWidth * 0.30;
    final goalBoxHeight = boxHeight * 0.42;
    final goalBoxLeft = marginX + (pitchWidth - goalBoxWidth) / 2;
    canvas.drawRect(Rect.fromLTWH(goalBoxLeft, marginY, goalBoxWidth, goalBoxHeight), linePaint);

    // Top Penalty Spot & Penalty Arc
    canvas.drawCircle(Offset(width * 0.5, marginY + boxHeight * 0.72), 2.5, spotPaint);
    final topArcRect = Rect.fromCircle(
      center: Offset(width * 0.5, marginY + boxHeight * 0.72),
      radius: pitchWidth * 0.13,
    );
    canvas.drawArc(topArcRect, 0.35, math.pi - 0.70, false, linePaint);

    // Bottom 18-yard Penalty Box & Arc
    final bottomBoxTop = height - marginY - boxHeight;
    canvas.drawRect(Rect.fromLTWH(boxLeft, bottomBoxTop, boxWidth, boxHeight), linePaint);
    final bottomArcRect = Rect.fromCircle(
      center: Offset(width * 0.5, bottomBoxTop + boxHeight * 0.28),
      radius: pitchWidth * 0.13,
    );
    canvas.drawArc(bottomArcRect, math.pi + 0.35, math.pi - 0.70, false, linePaint);

    // Corner Arcs
    const cornerR = 18.0;
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(marginX, marginY), radius: cornerR),
      0,
      math.pi / 2,
      false,
      linePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(width - marginX, marginY), radius: cornerR),
      math.pi / 2,
      math.pi / 2,
      false,
      linePaint,
    );

    // Twin Stadium Floodlights (Top-Left & Top-Right)
    final leftLight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.85, -0.95),
        radius: 1.1,
        colors: [
          const Color(0xFF34D399).withValues(alpha: 0.10 + pulseProgress * 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height * 0.55));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height * 0.55), leftLight);

    final rightLight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.85, -0.95),
        radius: 1.1,
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.06 + pulseProgress * 0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height * 0.55));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height * 0.55), rightLight);
  }

  @override
  bool shouldRepaint(covariant _TacticalFieldLinesPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress;
  }
}
