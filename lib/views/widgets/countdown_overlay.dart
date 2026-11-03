import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class CountdownOverlay extends StatelessWidget {
  final int count;

  const CountdownOverlay({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'HAZIRLAN!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$count',
              key: ValueKey(count),
              style: TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.w900,
                color: count == 1 ? AppColors.pitchGreen : AppColors.gold,
                shadows: [
                  Shadow(
                    color: (count == 1 ? AppColors.pitchGreen : AppColors.gold).withOpacity(0.6),
                    blurRadius: 30,
                  ),
                ],
              ),
            )
                .animate(key: ValueKey(count))
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1.1, 1.1),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 200.ms),
            const SizedBox(height: 20),
            const Text(
              'Ortak futbolcuyu ilk söyleyen kazanır!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
