import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StadiumBackground extends StatelessWidget {
  final Widget child;

  const StadiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(child: child),
    );
  }
}
