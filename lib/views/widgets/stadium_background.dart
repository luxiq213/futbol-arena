import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StadiumBackground extends StatelessWidget {
  final Widget child;

  const StadiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background
        Container(
          color: AppColors.background,
        ),

        // Top stadium floodlight glow
        Positioned(
          top: -120,
          left: -60,
          right: -60,
          height: 340,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 0.9,
                colors: [
                  AppColors.pitchGreen.withOpacity(0.18),
                  AppColors.pitchGreen.withOpacity(0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom right subtle glow
        Positioned(
          bottom: -100,
          right: -80,
          width: 300,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.electricBlue.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Pitch center circle hint (subtle watermark)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.45,
          left: -100,
          right: -100,
          height: 200,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.03,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        ),

        // Child Content
        SafeArea(child: child),
      ],
    );
  }
}
