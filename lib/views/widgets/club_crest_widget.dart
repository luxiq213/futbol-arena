import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/club_model.dart';

class ClubCrestWidget extends StatelessWidget {
  final ClubModel club;
  final double size;
  final bool showShortName;

  const ClubCrestWidget({
    super.key,
    required this.club,
    this.size = 64,
    this.showShortName = true,
  });

  @override
  Widget build(BuildContext context) {
    final width = size;
    final height = size * 1.18; // Traditional heraldic shield proportion

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shield Drop Shadow
          Positioned.fill(
            child: CustomPaint(
              painter: _ShieldShadowPainter(
                glowColor: club.primaryColor.withValues(alpha: 0.35),
              ),
            ),
          ),

          // Main Clipped Shield Body with Club Patterns
          ClipPath(
            clipper: const ShieldClipper(),
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Pattern Painter
                  CustomPaint(
                    painter: _ClubPatternPainter(
                      primary: club.primaryColor,
                      secondary: club.secondaryColor,
                      accent: club.accentColor,
                      pattern: club.pattern,
                    ),
                  ),

                  // Gloss / Enamel Sheen (Diagonal highlight across upper shield)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: height * 0.45,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.35),
                            Colors.white.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center Emblem with Club Short Name
          if (showShortName)
            Positioned(
              bottom: height * 0.22,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size * 0.12,
                  vertical: size * 0.04,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(size * 0.16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  club.shortName,
                  style: TextStyle(
                    fontSize: size * 0.21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Outer Shield Rim / Metallic Border
          Positioned.fill(
            child: CustomPaint(
              painter: _ShieldBorderPainter(
                borderColor: Colors.white.withValues(alpha: 0.45),
                accentColor: club.primaryColor,
                strokeWidth: size * 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Geometric Heraldic Shield Clipper
class ShieldClipper extends CustomClipper<Path> {
  const ShieldClipper();

  @override
  Path getClip(Size size) {
    return _createShieldPath(size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Path _createShieldPath(Size size) {
  final path = Path();
  final w = size.width;
  final h = size.height;

  // Top edge with slight crown curve
  path.moveTo(0, 0);
  path.lineTo(w, 0);

  // Vertical straight edges down to 60%
  path.lineTo(w, h * 0.60);

  // Curving down symmetrically to pointed tip
  path.quadraticBezierTo(w * 0.96, h * 0.88, w * 0.5, h);
  path.quadraticBezierTo(w * 0.04, h * 0.88, 0, h * 0.60);

  path.close();
  return path;
}

/// Painter for the club's signature striping / halving pattern
class _ClubPatternPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final Color? accent;
  final BadgePattern pattern;

  _ClubPatternPainter({
    required this.primary,
    required this.secondary,
    this.accent,
    required this.pattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (pattern) {
      case BadgePattern.halves:
        // Left half primary (e.g. Red), Right half secondary (e.g. Yellow)
        final pPaint = Paint()..color = primary;
        final sPaint = Paint()..color = secondary;
        canvas.drawRect(Rect.fromLTWH(0, 0, w / 2, h), pPaint);
        canvas.drawRect(Rect.fromLTWH(w / 2, 0, w / 2, h), sPaint);
        break;

      case BadgePattern.stripesVertical:
        // 5 alternating stripes (Primary, Secondary, Primary, Secondary, Primary)
        final stripeWidth = w / 5;
        for (int i = 0; i < 5; i++) {
          final paint = Paint()..color = (i % 2 == 0) ? primary : secondary;
          canvas.drawRect(Rect.fromLTWH(i * stripeWidth, 0, stripeWidth, h), paint);
        }
        break;

      case BadgePattern.diagonalSash:
        // Background primary, diagonal sash secondary
        final bgPaint = Paint()..color = primary;
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

        final sashPaint = Paint()..color = secondary;
        final sashPath = Path()
          ..moveTo(0, h * 0.25)
          ..lineTo(w * 0.75, 0)
          ..lineTo(w, 0)
          ..lineTo(w, h * 0.25)
          ..lineTo(w * 0.25, h)
          ..lineTo(0, h)
          ..close();
        canvas.drawPath(sashPath, sashPaint);
        break;

      case BadgePattern.solidWithTrim:
        // Solid primary base with center accent stripe and side accents
        final basePaint = Paint()..color = primary;
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), basePaint);

        // Center stripe
        final centerPaint = Paint()..color = secondary;
        final cWidth = w * 0.28;
        canvas.drawRect(Rect.fromLTWH((w - cWidth) / 2, 0, cWidth, h), centerPaint);

        // Thin accent lines if present
        if (accent != null) {
          final accPaint = Paint()..color = accent!;
          final thin = w * 0.05;
          canvas.drawRect(Rect.fromLTWH((w - cWidth) / 2 - thin, 0, thin, h), accPaint);
          canvas.drawRect(Rect.fromLTWH((w + cWidth) / 2, 0, thin, h), accPaint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ClubPatternPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.pattern != pattern;
  }
}

/// Painter for outer shield rim
class _ShieldBorderPainter extends CustomPainter {
  final Color borderColor;
  final Color accentColor;
  final double strokeWidth;

  _ShieldBorderPainter({
    required this.borderColor,
    required this.accentColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createShieldPath(size);

    // Outer bright edge
    final outerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawPath(path, outerPaint);
  }

  @override
  bool shouldRepaint(covariant _ShieldBorderPainter oldDelegate) => false;
}

/// Painter for shield drop glow
class _ShieldShadowPainter extends CustomPainter {
  final Color glowColor;

  _ShieldShadowPainter({required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createShieldPath(size);
    final paint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ShieldShadowPainter oldDelegate) => false;
}
