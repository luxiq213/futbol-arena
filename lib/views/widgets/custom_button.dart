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
    if (widget.isOutlined) {
      return SizedBox(
        height: widget.height,
        child: OutlinedButton(
          onPressed: widget.onPressed != null
              ? () {
                  GameFeedback.tick();
                  widget.onPressed!();
                }
              : null,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border, width: 1.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: AppColors.gold, size: 17),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isEnabled = widget.onPressed != null;
    final useTurf = widget.isTurfStyle &&
        (widget.backgroundColor == null || widget.backgroundColor == AppColors.pitchGreen);

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: (useTurf ? const Color(0xFF0A4F29) : AppColors.pitchGreen)
                        .withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Realistic Pitch Turf Background OR Solid Background
              if (useTurf)
                CustomPaint(
                  painter: _RealisticPitchTurfPainter(
                    isPressed: _isPressed,
                    isEnabled: isEnabled,
                  ),
                )
              else
                Container(
                  color: isEnabled
                      ? (widget.backgroundColor ?? AppColors.pitchGreen)
                      : AppColors.surfaceLight,
                ),

              // Interactive Button Surface
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onHighlightChanged: (val) => setState(() => _isPressed = val),
                  onTap: isEnabled && !widget.isLoading
                      ? () {
                          GameFeedback.tick();
                          widget.onPressed!();
                        }
                      : null,
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: widget.textColor,
                                  size: 17,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.text,
                                style: TextStyle(
                                  color: widget.textColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  shadows: useTurf
                                      ? [
                                          Shadow(
                                            color: Colors.black.withValues(alpha: 0.45),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter that renders authentic alternating mowed lawn turf stripes
/// and tactile stadium floodlight sheen for buttons
class _RealisticPitchTurfPainter extends CustomPainter {
  final bool isPressed;
  final bool isEnabled;

  const _RealisticPitchTurfPainter({
    required this.isPressed,
    required this.isEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    if (!isEnabled) {
      canvas.drawColor(AppColors.surfaceLight, BlendMode.src);
      return;
    }

    // 1. Alternating vertical lawn stripes (Authentic pitch mowing pattern)
    const stripeWidth = 14.0;
    final count = (size.width / stripeWidth).ceil() + 1;

    // Natural turf emerald green tones
    final lightTurf = Paint()..color = const Color(0xFF138848);
    final darkTurf = Paint()..color = const Color(0xFF0E703A);

    for (int i = 0; i < count; i++) {
      final x = i * stripeWidth;
      final paint = (i % 2 == 0) ? lightTurf : darkTurf;
      canvas.drawRect(Rect.fromLTWH(x, 0, stripeWidth, size.height), paint);
    }

    // 2. Micro-texture grass fiber grain (Subtle stippling simulation)
    final grainPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    for (double gx = 4; gx < size.width; gx += 8) {
      for (double gy = 4; gy < size.height; gy += 8) {
        canvas.drawCircle(Offset(gx, gy), 0.8, grainPaint);
      }
    }

    // 3. Top Floodlight Highlight Bevel (gives rich tactile 3D turf block feel)
    final bevelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isPressed ? 0.08 : 0.22),
          Colors.white.withValues(alpha: 0.04),
          Colors.transparent,
          const Color(0xFF042010).withValues(alpha: 0.45),
        ],
        stops: const [0.0, 0.14, 0.80, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, bevelPaint);

    // 4. Fine Pitch Line Border (Like stadium chalk line)
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _RealisticPitchTurfPainter oldDelegate) =>
      oldDelegate.isPressed != isPressed || oldDelegate.isEnabled != isEnabled;
}
