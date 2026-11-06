import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum AppNotificationType {
  success,
  gold,
  highlight,
  warning,
  error,
}

class AppNotification {
  static void show(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? message,
    AppNotificationType type = AppNotificationType.success,
    IconData? icon,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final effectiveSubtitle = subtitle ?? message;
    Color accentColor;
    IconData resolvedIcon;

    switch (type) {
      case AppNotificationType.success:
        accentColor = AppColors.greenLight;
        resolvedIcon = icon ?? Icons.check_circle_outline_rounded;
        break;
      case AppNotificationType.gold:
      case AppNotificationType.highlight:
        accentColor = AppColors.gold;
        resolvedIcon = icon ?? Icons.workspace_premium_outlined;
        break;
      case AppNotificationType.warning:
        accentColor = AppColors.warning;
        resolvedIcon = icon ?? Icons.info_outline_rounded;
        break;
      case AppNotificationType.error:
        accentColor = AppColors.error;
        resolvedIcon = icon ?? Icons.error_outline_rounded;
        break;
    }

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        padding: EdgeInsets.zero,
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xF50E2D20),
                Color(0xF5071912),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.65),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: accentColor.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.45),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Icon(
                    resolvedIcon,
                    color: accentColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                    if (effectiveSubtitle != null && effectiveSubtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        effectiveSubtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
