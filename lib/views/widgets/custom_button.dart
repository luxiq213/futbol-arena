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
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Widget childButton;
    if (widget.isOutlined) {
      childButton = SizedBox(
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
              color: isEnabled
                  ? AppColors.gold.withValues(alpha: 0.72)
                  : AppColors.border,
              width: 1.25,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            backgroundColor: const Color(0xFF0A1D16).withValues(alpha: 0.78),
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
                      fontSize: 13.5,
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
    } else {
      final bgColor = widget.backgroundColor ?? AppColors.pitchGreen;
      final deeperBg = Color.lerp(bgColor, Colors.black, 0.28)!;

      childButton = Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: isEnabled
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bgColor, deeperBg],
                )
              : null,
          color: isEnabled ? null : AppColors.surfaceLight,
          border: Border.all(
            color: isEnabled
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.08),
            width: 0.9,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: isEnabled
                ? () {
                    GameFeedback.tick();
                    widget.onPressed!();
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(widget.textColor),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: isEnabled
                                  ? widget.textColor
                                  : AppColors.textMuted,
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
                                  color: isEnabled
                                      ? widget.textColor
                                      : AppColors.textMuted,
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
            ),
          ),
        ),
      );
    }

    return Listener(
      onPointerDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: (_isPressed && isEnabled) ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: childButton,
      ),
    );
  }
}
