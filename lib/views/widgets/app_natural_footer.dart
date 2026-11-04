import 'package:flutter/material.dart';
import 'app_floating_glass_footer.dart';

/// Backward-compatible alias for AppFloatingGlassFooter
class AppNaturalFooter extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const AppNaturalFooter({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppFloatingGlassFooter(
      activeIndex: activeIndex,
      onTabSelected: onTabSelected,
    );
  }
}
