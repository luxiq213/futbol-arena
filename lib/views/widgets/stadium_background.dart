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
          // Top soft stadium floodlight ambient glow (no harsh lines or corner rectangles)
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            height: 260,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.1,
                    colors: [
                      AppColors.pitchGreen.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
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
