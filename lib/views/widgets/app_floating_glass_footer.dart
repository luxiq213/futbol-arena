import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/sound_effects.dart';
import '../../providers/locale_provider.dart';

class AppFloatingGlassFooter extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final PageController? pageController;

  const AppFloatingGlassFooter({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
    this.pageController,
  });

  double _resolvePosition(double fallback) {
    final ctrl = pageController;
    if (ctrl != null && ctrl.hasClients && ctrl.position.haveDimensions) {
      return (ctrl.page ?? fallback).clamp(0.0, 2.0);
    }
    return fallback.clamp(0.0, 2.0);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final items = [
      (icon: Icons.sports_soccer, label: loc.t('tab_games')),
      (icon: Icons.hub_rounded, label: loc.t('tab_lobby')),
      (icon: Icons.person_outline, label: loc.t('tab_profile')),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.48),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF061610).withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1.0,
              ),
            ),
            child: pageController != null
                ? AnimatedBuilder(
                    animation: pageController!,
                    builder: (context, _) => _buildInteractiveTrack(
                      items: items,
                      currentPos: _resolvePosition(activeIndex.toDouble()),
                    ),
                  )
                : TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: activeIndex.toDouble()),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    builder: (context, tweenPos, _) => _buildInteractiveTrack(
                      items: items,
                      currentPos: tweenPos.clamp(0.0, 2.0),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveTrack({
    required List<({IconData icon, String label})> items,
    required double currentPos,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 4.0;
        final tabWidth =
            (constraints.maxWidth - gap * (items.length - 1)) / items.length;
        final pillLeft = currentPos * (tabWidth + gap);

        return Stack(
          children: [
            // Continuous sliding frosted capsule + pitch-green accent bar
            Positioned(
              left: pillLeft,
              top: 0,
              bottom: 0,
              width: tabWidth,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Container(
                    width: 16,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: AppColors.pitchGreen,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pitchGreen.withValues(alpha: 0.55),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Tab interactive labels & icons smoothly morphed by proximity
            Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  Expanded(
                    child: _buildGlassTabItem(
                      index: i,
                      icon: items[i].icon,
                      label: items[i].label,
                      focus: (1.0 - (currentPos - i).abs()).clamp(0.0, 1.0),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlassTabItem({
    required int index,
    required IconData icon,
    required String label,
    required double focus,
  }) {
    final inactiveColor = const Color(0xFF94A3B8).withValues(alpha: 0.68);
    final fgColor = Color.lerp(inactiveColor, Colors.white, focus)!;
    final iconScale = lerpDouble(0.95, 1.06, focus)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: () {
          GameFeedback.tick();
          onTabSelected(index);
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 7, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: iconScale,
                child: Icon(
                  icon,
                  color: fgColor,
                  size: 19,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: focus > 0.5 ? FontWeight.w700 : FontWeight.w500,
                  color: fgColor,
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
