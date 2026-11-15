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
    final radius = BorderRadius.circular(size * 0.28);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.32),
          width: (size * 0.035).clamp(1.0, 2.0),
        ),
        boxShadow: [
          BoxShadow(
            color: club.primaryColor.withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((size * 0.28) - 1.2),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            // Clean Club Pattern
            CustomPaint(
              painter: _ClubPatternPainter(
                primary: club.primaryColor,
                secondary: club.secondaryColor,
                accent: club.accentColor,
                pattern: club.pattern,
              ),
            ),

            // Top Soft Gloss Highlight
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size * 0.45,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.26),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Center Medallion or Short Name
            if (showShortName)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size * 0.12,
                    vertical: size * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(size * 0.14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    club.shortName,
                    style: TextStyle(
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Container(
                  width: size * 0.40,
                  height: size * 0.40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background.withValues(alpha: 0.80),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.75),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      club.isNationalTeam ? Icons.flag_rounded : Icons.sports_soccer,
                      size: size * 0.23,
                      color: club.isNationalTeam ? AppColors.greenLight : AppColors.gold,
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
