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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              // Neutral, colorless dark smoked glass
              color: const Color(0xFF0C1322).withValues(alpha: 0.68),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.0,
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
                const SizedBox(width: 4),
                // 2. Sıralama
                Expanded(
                  child: _buildGlassTabItem(
                    index: 1,
                    icon: Icons.military_tech_outlined,
                    label: 'Sıralama',
                    isActive: activeIndex == 1,
                  ),
                ),
                const SizedBox(width: 4),
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
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          GameFeedback.tick();
          onTabSelected(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            // Colorless frosted capsule for active tab
            color: isActive
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.20)
                  : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? Colors.white
                    : const Color(0xFF94A3B8).withValues(alpha: 0.65),
                size: 19,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? Colors.white
                      : const Color(0xFF94A3B8).withValues(alpha: 0.65),
                  letterSpacing: 0.2,
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 2),
                Container(
                  width: 12,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.pitchGreen,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
