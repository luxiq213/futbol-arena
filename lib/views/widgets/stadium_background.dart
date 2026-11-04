import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StadiumBackground extends StatefulWidget {
  final Widget child;
  final bool showGrass;

  const StadiumBackground({
    super.key,
    required this.child,
    this.showGrass = true,
  });

  @override
  State<StadiumBackground> createState() => _StadiumBackgroundState();
}

class _StadiumBackgroundState extends State<StadiumBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _windController;

  @override
  void initState() {
    super.initState();
    _windController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _windController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base Atmosphere Gradient (Night Navy to Deep Turf Green)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF070E1E), // Night sky
                  Color(0xFF091624),
                  Color(0xFF081E19), // Turf twilight
                  Color(0xFF04140F), // Deep pitch grass base
                ],
                stops: [0.0, 0.45, 0.80, 1.0],
              ),
            ),
          ),

          // Animated Wind-Blown Grass Field Layer
          if (widget.showGrass)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 220,
              child: AnimatedBuilder(
                animation: _windController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _RealisticWindGrassPainter(
                      progress: _windController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),

          // Subtle Readability Vignette
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0.65),
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xFF04140F).withValues(alpha: 0.70),
                    ],
                    stops: const [0.0, 0.25, 0.70, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Foreground Interactive Content
          SafeArea(child: widget.child),
        ],
      ),
    );
  }
}

/// Custom painter for organic multi-layered grass blades swaying in the wind
class _RealisticWindGrassPainter extends CustomPainter {
  final double progress;

  _RealisticWindGrassPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Wind wave time variables
    final t = progress * 2 * math.pi;

    // --- LAYER 1: Deep Background Grass (Dark shadow blades, dense) ---
    final backPaint = Paint()..style = PaintingStyle.fill;
    _drawGrassLayer(
      canvas: canvas,
      width: width,
      height: height,
      bladeCount: 75,
      minHeight: 50,
      maxHeight: 110,
      baseColor: const Color(0xFF02120A),
      tipColor: const Color(0xFF0A331D),
      time: t,
      windFactor: 14.0,
      freq: 1.4,
      paint: backPaint,
      seed: 42,
    );

    // --- LAYER 2: Mid-ground Grass (Rich emerald football pitch turf) ---
    final midPaint = Paint()..style = PaintingStyle.fill;
    _drawGrassLayer(
      canvas: canvas,
      width: width,
      height: height,
      bladeCount: 85,
      minHeight: 70,
      maxHeight: 140,
      baseColor: const Color(0xFF052414),
      tipColor: const Color(0xFF106838),
      time: t + 0.8,
      windFactor: 19.0,
      freq: 1.8,
      paint: midPaint,
      seed: 88,
    );

    // --- LAYER 3: Foreground Grass (Slender, illuminated tips with breeze) ---
    final frontPaint = Paint()..style = PaintingStyle.fill;
    _drawGrassLayer(
      canvas: canvas,
      width: width,
      height: height,
      bladeCount: 95,
      minHeight: 85,
      maxHeight: 175,
      baseColor: const Color(0xFF08331E),
      tipColor: const Color(0xFF1CA359),
      time: t + 1.6,
      windFactor: 24.0,
      freq: 2.2,
      paint: frontPaint,
      seed: 137,
    );
  }

  void _drawGrassLayer({
    required Canvas canvas,
    required double width,
    required double height,
    required int bladeCount,
    required double minHeight,
    required double maxHeight,
    required Color baseColor,
    required Color tipColor,
    required double time,
    required double windFactor,
    required double freq,
    required Paint paint,
    required int seed,
  }) {
    final step = width / bladeCount;

    for (int i = 0; i < bladeCount; i++) {
      // Deterministic procedural pseudorandom variation per blade
      final pseudoRand = math.sin((i + seed) * 12.9898).abs();
      final pseudoRand2 = math.cos((i + seed) * 78.233).abs();

      final x = i * step + (pseudoRand - 0.5) * (step * 0.8);
      final bladeHeight = minHeight + (maxHeight - minHeight) * pseudoRand;
      final bladeWidth = 2.5 + pseudoRand2 * 2.5;

      // Realistic wind wave sway formula (primary wind gust + secondary flutter)
      final wave1 = math.sin(time * freq + x * 0.015);
      final wave2 = math.cos(time * (freq * 1.6) + x * 0.035) * 0.35;
      final gust = (wave1 + wave2) * windFactor;

      final baseY = height;
      final tipX = x + gust;
      final tipY = height - bladeHeight;
      final ctrlX = x + gust * 0.45;
      final ctrlY = height - (bladeHeight * 0.55);

      // Gradient shader from dark soil root to wind-swept tip
      paint.shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [baseColor, tipColor],
      ).createShader(Rect.fromLTWH(x - bladeWidth, tipY, bladeWidth * 2 + gust.abs(), bladeHeight));

      final path = Path();
      path.moveTo(x - bladeWidth * 0.5, baseY);
      path.quadraticBezierTo(ctrlX - bladeWidth * 0.2, ctrlY, tipX, tipY);
      path.quadraticBezierTo(ctrlX + bladeWidth * 0.2, ctrlY, x + bladeWidth * 0.5, baseY);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RealisticWindGrassPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
