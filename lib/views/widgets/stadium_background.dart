import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StadiumBackground extends StatefulWidget {
  final Widget child;
  final bool showSkyEffects;

  const StadiumBackground({
    super.key,
    required this.child,
    this.showSkyEffects = true,
  });

  @override
  State<StadiumBackground> createState() => _StadiumBackgroundState();
}

class _StadiumBackgroundState extends State<StadiumBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Deep Midnight Stadium Night Sky Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF030712), // Deep night zenith
                  Color(0xFF071126), // Upper atmosphere midnight
                  Color(0xFF0B1B3D), // Night match twilight
                  Color(0xFF0F244C), // Horizon dusk blue
                  Color(0xFF091C2E), // Distant stadium aura base
                ],
                stops: [0.0, 0.30, 0.60, 0.85, 1.0],
              ),
            ),
          ),

          // 2. Realistic Night Sky Stars & Atmospheric Haze
          if (widget.showSkyEffects)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _NightSkyAtmospherePainter(
                      pulseProgress: _ambientController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),

          // 3. Volumetric Stadium Floodlight Beams
          if (widget.showSkyEffects)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _StadiumFloodlightsPainter(
                      beamProgress: _ambientController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),

          // 4. Subtle Contrast Vignette for Content Readability
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.transparent,
                      AppColors.background.withValues(alpha: 0.82),
                    ],
                    stops: const [0.0, 0.22, 0.72, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 5. Interactive Content
          SafeArea(child: widget.child),
        ],
      ),
    );
  }
}

/// Custom painter for distant twinkling night stars and soft atmospheric clouds
class _NightSkyAtmospherePainter extends CustomPainter {
  final double pulseProgress;

  _NightSkyAtmospherePainter({required this.pulseProgress});

  // Pre-calculated deterministic star positions (x: 0..1, y: 0..1, size, baseAlpha)
  static final List<List<double>> _stars = [
    [0.08, 0.05, 1.2, 0.45],
    [0.15, 0.12, 1.5, 0.70],
    [0.22, 0.04, 1.0, 0.40],
    [0.28, 0.16, 1.8, 0.85],
    [0.35, 0.08, 1.1, 0.50],
    [0.42, 0.19, 1.4, 0.60],
    [0.50, 0.06, 2.0, 0.90],
    [0.58, 0.14, 1.3, 0.55],
    [0.65, 0.03, 1.1, 0.40],
    [0.72, 0.17, 1.6, 0.75],
    [0.80, 0.09, 1.2, 0.60],
    [0.88, 0.15, 1.7, 0.80],
    [0.94, 0.07, 1.0, 0.45],
    [0.12, 0.25, 1.3, 0.50],
    [0.25, 0.32, 1.5, 0.65],
    [0.38, 0.28, 1.1, 0.40],
    [0.54, 0.35, 1.6, 0.70],
    [0.68, 0.29, 1.2, 0.55],
    [0.82, 0.33, 1.4, 0.60],
    [0.91, 0.26, 1.0, 0.35],
    [0.05, 0.38, 1.2, 0.45],
    [0.31, 0.42, 1.5, 0.60],
    [0.62, 0.45, 1.3, 0.50],
    [0.77, 0.40, 1.7, 0.75],
    [0.85, 0.48, 1.1, 0.40],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final starPaint = Paint()..style = PaintingStyle.fill;

    // Draw twinkling pinpoint stars across the night sky
    for (int i = 0; i < _stars.length; i++) {
      final s = _stars[i];
      final x = s[0] * width;
      final y = s[1] * height;
      final radius = s[2];
      final baseAlpha = s[3];

      // Subtle organic twinkle
      final twinkle = math.sin((pulseProgress * math.pi * 2) + i * 0.7);
      final alpha = (baseAlpha + twinkle * 0.25).clamp(0.15, 0.95);

      starPaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Soft atmospheric stadium horizon haze
    final hazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF16325C).withValues(alpha: 0.16 + pulseProgress * 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55],
      ).createShader(Rect.fromLTWH(0, height * 0.45, width, height * 0.55));

    canvas.drawRect(Rect.fromLTWH(0, height * 0.45, width, height * 0.55), hazePaint);
  }

  @override
  bool shouldRepaint(covariant _NightSkyAtmospherePainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress;
  }
}

/// Volumetric stadium floodlight beams illuminating the night sky
class _StadiumFloodlightsPainter extends CustomPainter {
  final double beamProgress;

  _StadiumFloodlightsPainter({required this.beamProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Subtle breathing intensity for volumetric dust/haze in light cones
    final breath = math.sin(beamProgress * math.pi) * 0.025;

    // 1. Top-Left Stadium Floodlight Beam (Sweeping downward-right into the pitch)
    _drawLightBeam(
      canvas: canvas,
      origin: Offset(width * 0.05, -10),
      targetCenter: Offset(width * 0.55, height * 0.70),
      beamWidth: width * 0.48,
      beamLength: height * 0.85,
      coreAlpha: 0.075 + breath,
    );

    // 2. Top-Right Stadium Floodlight Beam (Sweeping downward-left into the pitch)
    _drawLightBeam(
      canvas: canvas,
      origin: Offset(width * 0.95, -10),
      targetCenter: Offset(width * 0.45, height * 0.70),
      beamWidth: width * 0.48,
      beamLength: height * 0.85,
      coreAlpha: 0.075 + breath,
    );

    // 3. Left Secondary Cross-Beam
    _drawLightBeam(
      canvas: canvas,
      origin: Offset(-15, height * 0.18),
      targetCenter: Offset(width * 0.70, height * 0.50),
      beamWidth: width * 0.38,
      beamLength: height * 0.65,
      coreAlpha: 0.045 + breath * 0.5,
    );

    // 4. Right Secondary Cross-Beam
    _drawLightBeam(
      canvas: canvas,
      origin: Offset(width + 15, height * 0.18),
      targetCenter: Offset(width * 0.30, height * 0.50),
      beamWidth: width * 0.38,
      beamLength: height * 0.65,
      coreAlpha: 0.045 + breath * 0.5,
    );
  }

  void _drawLightBeam({
    required Canvas canvas,
    required Offset origin,
    required Offset targetCenter,
    required double beamWidth,
    required double beamLength,
    required double coreAlpha,
  }) {
    final dx = targetCenter.dx - origin.dx;
    final dy = targetCenter.dy - origin.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return;

    final nx = -dy / dist;
    final ny = dx / dist;

    final p1 = Offset(origin.dx, origin.dy);
    final p2 = Offset(targetCenter.dx + nx * (beamWidth * 0.5), targetCenter.dy + ny * (beamWidth * 0.5));
    final p3 = Offset(targetCenter.dx - nx * (beamWidth * 0.5), targetCenter.dy - ny * (beamWidth * 0.5));

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    final beamPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (origin.dx / (targetCenter.dx * 1.5)) * 2 - 1,
          (origin.dy / (targetCenter.dy * 1.5)) * 2 - 1,
        ),
        radius: 1.2,
        colors: [
          const Color(0xFFE2EDFF).withValues(alpha: coreAlpha),
          const Color(0xFF94B8FF).withValues(alpha: coreAlpha * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(path.getBounds());

    canvas.drawPath(path, beamPaint);
  }

  @override
  bool shouldRepaint(covariant _StadiumFloodlightsPainter oldDelegate) {
    return oldDelegate.beamProgress != beamProgress;
  }
}
