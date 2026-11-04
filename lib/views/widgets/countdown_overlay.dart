import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CountdownOverlay extends StatelessWidget {
  final int count;

  const CountdownOverlay({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'HAZIRLAN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$count',
              key: ValueKey(count),
              style: const TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w900,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Süre dolmadan ortak futbolcuyu sesli olarak söyle.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.silver,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
