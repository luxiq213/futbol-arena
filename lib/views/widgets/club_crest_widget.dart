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
    this.showShortName = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft colored club aura underneath the shield
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: club.primaryColor.withValues(alpha: 0.28),
                    blurRadius: size * 0.22,
                    spreadRadius: -size * 0.08,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),

          // Heraldic shield silhouette with club kit pattern + gloss
          Positioned.fill(
            child: ClipPath(
              clipper: const _ShieldCrestClipper(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _ClubPatternPainter(
                      primary: club.primaryColor,
                      secondary: club.secondaryColor,
                      accent: club.accentColor,
                      pattern: club.pattern,
                    ),
                  ),
                  // Diagonal broadcast sheen
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: size * 0.48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.28),
                            Colors.white.withValues(alpha: 0.04),
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

          // Crisp metallic shield rim
          Positioned.fill(
            child: CustomPaint(
              painter: _ShieldBorderPainter(
                strokeWidth: (size * 0.036).clamp(1.1, 2.2),
              ),
            ),
          ),

          // Center Medallion or Short Name
          if (showShortName)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size * 0.13,
                vertical: size * 0.045,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF04110B).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(size * 0.13),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.34),
                  width: 1.0,
                ),
              ),
              child: Text(
                club.shortName,
                style: TextStyle(
                  fontSize: size * 0.21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
            )
          else
            Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF04110B).withValues(alpha: 0.84),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.82),
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Icon(
                  club.isNationalTeam ? Icons.flag_rounded : Icons.sports_soccer,
                  size: size * 0.21,
                  color: club.isNationalTeam ? AppColors.greenLight : AppColors.gold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Path _buildShieldPath(Size size) {
  final w = size.width;
  final h = size.height;
  return Path()
    ..moveTo(w * 0.10, h * 0.08)
    ..quadraticBezierTo(w * 0.50, 0.0, w * 0.90, h * 0.08)
    ..lineTo(w * 0.90, h * 0.52)
    ..cubicTo(w * 0.90, h * 0.77, w * 0.64, h * 0.91, w * 0.50, h * 0.98)
    ..cubicTo(w * 0.36, h * 0.91, w * 0.10, h * 0.77, w * 0.10, h * 0.52)
    ..close();
}

class _ShieldCrestClipper extends CustomClipper<Path> {
  const _ShieldCrestClipper();

  @override
  Path getClip(Size size) => _buildShieldPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ShieldBorderPainter extends CustomPainter {
  final double strokeWidth;
  const _ShieldBorderPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildShieldPath(size);
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.62),
          Colors.white.withValues(alpha: 0.22),
          AppColors.gold.withValues(alpha: 0.45),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _ShieldBorderPainter oldDelegate) =>
      oldDelegate.strokeWidth != strokeWidth;
}

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
        final pPaint = Paint()..color = primary;
        final sPaint = Paint()..color = secondary;
        canvas.drawRect(Rect.fromLTWH(0, 0, w / 2, h), pPaint);
        canvas.drawRect(Rect.fromLTWH(w / 2, 0, w / 2, h), sPaint);
        break;

      case BadgePattern.stripesVertical:
        final stripeWidth = w / 5;
        for (int i = 0; i < 5; i++) {
          final paint = Paint()..color = (i % 2 == 0) ? primary : secondary;
          canvas.drawRect(Rect.fromLTWH(i * stripeWidth, 0, stripeWidth, h), paint);
        }
        break;

      case BadgePattern.diagonalSash:
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
        final bgPaint = Paint()..color = primary;
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

        final trimPaint = Paint()..color = secondary;
        canvas.drawRect(Rect.fromLTWH(w * 0.38, 0, w * 0.24, h), trimPaint);
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
