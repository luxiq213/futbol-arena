import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/sound_effects.dart';

class AppFloatingGlassFooter extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const AppFloatingGlassFooter({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.deepPurple.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              // Translucent frosted glass effect
              color: AppColors.surface.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.02),
                  AppColors.deepPurple.withValues(alpha: 0.15),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
            child: Row(
              children: [
                // 1. Oyunlar
                Expanded(
                  child: _buildGlassTabItem(
                    index: 0,
                    icon: Icons.sports_soccer,
                    label: 'Oyunlar',
                    isActive: activeIndex == 0,
                  ),
                ),
                const SizedBox(width: 6),
                // 2. Sıralama
                Expanded(
                  child: _buildGlassTabItem(
                    index: 1,
                    icon: Icons.military_tech_outlined,
                    label: 'Sıralama',
                    isActive: activeIndex == 1,
                  ),
                ),
                const SizedBox(width: 6),
                // 3. Profil
                Expanded(
                  child: _buildGlassTabItem(
                    index: 2,
                    icon: Icons.person_outline,
                    label: 'Profil',
                    isActive: activeIndex == 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTabItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          GameFeedback.tick();
          onTabSelected(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.deepPurple.withValues(alpha: 0.65)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppColors.gold.withValues(alpha: 0.55)
                  : Colors.transparent,
              width: 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.gold : AppColors.silver.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.gold : AppColors.silver.withValues(alpha: 0.7),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
