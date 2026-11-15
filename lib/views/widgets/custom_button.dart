import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/sound_effects.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color textColor;
  final bool isLoading;
  final bool isOutlined;
  final bool isTurfStyle;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.isLoading = false,
    this.isOutlined = false,
    this.isTurfStyle = true,
    this.height = 46,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    if (widget.isOutlined) {
      return SizedBox(
        height: widget.height,
        child: OutlinedButton(
          onPressed: isEnabled
              ? () {
                  GameFeedback.tick();
                  widget.onPressed!();
                }
              : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: BorderSide(
              color: isEnabled ? AppColors.gold.withValues(alpha: 0.65) : AppColors.border,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: AppColors.surface.withValues(alpha: 0.65),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: AppColors.gold, size: 17),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bgColor = widget.backgroundColor ?? AppColors.pitchGreen;

    return SizedBox(
      height: widget.height,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                GameFeedback.tick();
                widget.onPressed!();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: AppColors.surfaceLight,
          foregroundColor: widget.textColor,
          disabledForegroundColor: AppColors.textMuted,
          elevation: isEnabled ? 2 : 0,
          shadowColor: bgColor.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: isEnabled ? widget.textColor : AppColors.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color: isEnabled ? widget.textColor : AppColors.textMuted,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
