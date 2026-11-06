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
      color: const Color(0xFF061410),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Football Pitch Lawn Mowing Bands & Night Atmosphere
          Positioned.fill(
            child: CustomPaint(
              painter: _FootballPitchBasePainter(),
            ),
          ),

          // 2. Realistic Tactical Pitch Markings & Subtle Floodlight Beams
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

          // 3. Vignette Overlay for UI Contrast & Readability
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF05120D).withValues(alpha: 0.70),
                      const Color(0xFF061912).withValues(alpha: 0.35),
                      const Color(0xFF04100B).withValues(alpha: 0.75),
                      const Color(0xFF020A07).withValues(alpha: 0.88),
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

/// Paints the alternating cut turf lawn pattern of an elite European football pitch
class _FootballPitchBasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Dark lush pitch tones
    const darkStripe = Color(0xFF051710);
    const lightStripe = Color(0xFF082218);

    const stripeHeight = 64.0;
    final count = (height / stripeHeight).ceil() + 1;

    for (int i = 0; i < count; i++) {
      final y = i * stripeHeight;
      final paint = Paint()
        ..color = (i % 2 == 0) ? lightStripe : darkStripe
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, y, width, stripeHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints subtle stadium chalk lines (Center circle, halfway line, penalty box arc, floodlight sheen)
class _TacticalFieldLinesPainter extends CustomPainter {
  final double pulseProgress;

  _TacticalFieldLinesPainter({required this.pulseProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final lineAlpha = 0.08 + pulseProgress * 0.03;
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: lineAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final glowPaint = Paint()
      ..color = AppColors.pitchGreen.withValues(alpha: 0.04 + pulseProgress * 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Center circle & Halfway line across the middle-bottom
    final centerY = height * 0.58;
    final centerCircleRadius = width * 0.34;

    // Halfway line
    canvas.drawLine(Offset(0, centerY), Offset(width, centerY), linePaint);

    // Center circle
    final center = Offset(width * 0.5, centerY);
    canvas.drawCircle(center, centerCircleRadius, glowPaint);
    canvas.drawCircle(center, centerCircleRadius, linePaint);

    // Center spot (dot)
    final spotPaint = Paint()
      ..color = Colors.white.withValues(alpha: lineAlpha * 1.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, spotPaint);

    // Penalty box outline (subtle at top or bottom)
    final boxWidth = width * 0.65;
    final boxHeight = height * 0.16;
    final boxLeft = (width - boxWidth) / 2;

    // Top penalty box
    final topBoxRect = Rect.fromLTWH(boxLeft, 0, boxWidth, boxHeight);
    canvas.drawRect(topBoxRect, linePaint);

    // Top penalty arc
    final arcRect = Rect.fromCircle(
      center: Offset(width * 0.5, boxHeight),
      radius: width * 0.16,
    );
    canvas.drawArc(arcRect, 0, math.pi, false, linePaint);

    // Corner arcs
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 0), radius: 24),
      0,
      math.pi / 2,
      false,
      linePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(width, 0), radius: 24),
      math.pi / 2,
      math.pi / 2,
      false,
      linePaint,
    );

    // Subtle atmospheric floodlight corner glow
    final floodlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.8, -0.9),
        radius: 1.0,
        colors: [
          const Color(0xFF10B981).withValues(alpha: 0.07 + pulseProgress * 0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height * 0.5));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height * 0.5), floodlightPaint);
  }

  @override
  bool shouldRepaint(covariant _TacticalFieldLinesPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress;
  }
}
