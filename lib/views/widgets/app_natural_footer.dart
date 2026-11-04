import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppNaturalFooter extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTabSelected;

  const AppNaturalFooter({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32, bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // 1. Oyunlar
          Expanded(
            child: _buildFooterItem(
              index: 0,
              icon: Icons.sports_soccer,
              label: 'Oyunlar',
              isActive: activeIndex == 0,
            ),
          ),
          // 2. Sıralama
          Expanded(
            child: _buildFooterItem(
              index: 1,
              icon: Icons.military_tech_outlined,
              label: 'Sıralama',
              isActive: activeIndex == 1,
            ),
          ),
          // 3. Profil
          Expanded(
            child: _buildFooterItem(
              index: 2,
              icon: Icons.person_outline,
              label: 'Profil',
              isActive: activeIndex == 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTabSelected(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.gold : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.gold : AppColors.textMuted,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 16,
                height: 2,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
