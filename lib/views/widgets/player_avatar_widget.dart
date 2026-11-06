import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FootballerAvatarPreset {
  final String id;
  final String name;
  final String roleLabel;
  final String jerseyNumber;
  final Color bgPrimary;
  final Color bgSecondary;
  final Color jerseyPrimary;
  final Color jerseySecondary;
  final Color skinColor;
  final Color hairColor;
  final FootballerHairStyle hairStyle;
  final FootballerAccessory accessory;

  const FootballerAvatarPreset({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.jerseyNumber,
    required this.bgPrimary,
    required this.bgSecondary,
    required this.jerseyPrimary,
    required this.jerseySecondary,
    required this.skinColor,
    required this.hairColor,
    this.hairStyle = FootballerHairStyle.shortModern,
    this.accessory = FootballerAccessory.none,
  });
}

enum FootballerHairStyle {
  shortModern,
  spikyFade,
  bleachedBlonde,
  longBand,
  curlyHeadband,
  classicParted,
  longMaestro,
  buzzCut,
}

enum FootballerAccessory {
  none,
  goldCrown,
  captainBand,
  keeperGloves,
  beard,
  tacticalSuit,
  glasses,
}

class PlayerAvatarRegistry {
  static const List<FootballerAvatarPreset> presets = [
    FootballerAvatarPreset(
      id: 'goat_10',
      name: 'Leo #10',
      roleLabel: 'Efsane 10 Numara',
      jerseyNumber: '10',
      bgPrimary: Color(0xFF0E3756),
      bgSecondary: Color(0xFF071B2C),
      jerseyPrimary: Color(0xFF5BC0BE),
      jerseySecondary: Color(0xFFFFFFFF),
      skinColor: Color(0xFFF1C27D),
      hairColor: Color(0xFF2B1E16),
      hairStyle: FootballerHairStyle.shortModern,
      accessory: FootballerAccessory.goldCrown,
    ),
    FootballerAvatarPreset(
      id: 'striker_7',
      name: 'Ronaldo #7',
      roleLabel: 'Elit Gol Makinesi',
      jerseyNumber: '7',
      bgPrimary: Color(0xFF4C0D19),
      bgSecondary: Color(0xFF1F050B),
      jerseyPrimary: Color(0xFFDC2626),
      jerseySecondary: Color(0xFF15803D),
      skinColor: Color(0xFFE0AC69),
      hairColor: Color(0xFF1A1412),
      hairStyle: FootballerHairStyle.spikyFade,
      accessory: FootballerAccessory.none,
    ),
    FootballerAvatarPreset(
      id: 'icardi_9',
      name: 'Kral #9',
      roleLabel: 'Süper Lig Gol Kralı',
      jerseyNumber: '9',
      bgPrimary: Color(0xFF4D1218),
      bgSecondary: Color(0xFF2B0B0E),
      jerseyPrimary: Color(0xFFA90432),
      jerseySecondary: Color(0xFFFDB912),
      skinColor: Color(0xFFF1C27D),
      hairColor: Color(0xFFFDE047),
      hairStyle: FootballerHairStyle.bleachedBlonde,
      accessory: FootballerAccessory.beard,
    ),
    FootballerAvatarPreset(
      id: 'wonderkid_19',
      name: 'Harika Çocuk #19',
      roleLabel: 'Genç Yıldız Playmaker',
      jerseyNumber: '19',
      bgPrimary: Color(0xFF1E293B),
      bgSecondary: Color(0xFF0F172A),
      jerseyPrimary: Color(0xFFFFFFFF),
      jerseySecondary: Color(0xFFF59E0B),
      skinColor: Color(0xFFF5CBA7),
      hairColor: Color(0xFF2E1D12),
      hairStyle: FootballerHairStyle.classicParted,
      accessory: FootballerAccessory.none,
    ),
    FootballerAvatarPreset(
      id: 'fener_10',
      name: 'Kaptan #10',
      roleLabel: 'Kadıköy Maestrosu',
      jerseyNumber: '10',
      bgPrimary: Color(0xFF0F2547),
      bgSecondary: Color(0xFF071326),
      jerseyPrimary: Color(0xFFFFED00),
      jerseySecondary: Color(0xFF002D72),
      skinColor: Color(0xFFE0AC69),
      hairColor: Color(0xFF1C1917),
      hairStyle: FootballerHairStyle.buzzCut,
      accessory: FootballerAccessory.captainBand,
    ),
    FootballerAvatarPreset(
      id: 'captain_4',
      name: 'Kara Kartal #4',
      roleLabel: 'Savunma Bakanı',
      jerseyNumber: '4',
      bgPrimary: Color(0xFF27272A),
      bgSecondary: Color(0xFF09090B),
      jerseyPrimary: Color(0xFF18181B),
      jerseySecondary: Color(0xFFFFFFFF),
      skinColor: Color(0xFFD2996C),
      hairColor: Color(0xFF18181B),
      hairStyle: FootballerHairStyle.spikyFade,
      accessory: FootballerAccessory.captainBand,
    ),
    FootballerAvatarPreset(
      id: 'samba_11',
      name: 'Sambacı #11',
      roleLabel: 'Brezilyalı Sihirbaz',
      jerseyNumber: '11',
      bgPrimary: Color(0xFF064E3B),
      bgSecondary: Color(0xFF022C22),
      jerseyPrimary: Color(0xFFFACC15),
      jerseySecondary: Color(0xFF15803D),
      skinColor: Color(0xFF8D5524),
      hairColor: Color(0xFF14110F),
      hairStyle: FootballerHairStyle.curlyHeadband,
      accessory: FootballerAccessory.none,
    ),
    FootballerAvatarPreset(
      id: 'viking_9',
      name: 'Viking #9',
      roleLabel: 'Kuzeyli Gol Canavarı',
      jerseyNumber: '9',
      bgPrimary: Color(0xFF0C4A6E),
      bgSecondary: Color(0xFF082F49),
      jerseyPrimary: Color(0xFF38BDF8),
      jerseySecondary: Color(0xFFFFFFFF),
      skinColor: Color(0xFFFAD7B8),
      hairColor: Color(0xFFFEF08A),
      hairStyle: FootballerHairStyle.longBand,
      accessory: FootballerAccessory.none,
    ),
    FootballerAvatarPreset(
      id: 'panther_1',
      name: 'Panter #1',
      roleLabel: 'Efsane Kaleci',
      jerseyNumber: '1',
      bgPrimary: Color(0xFF065F46),
      bgSecondary: Color(0xFF064E3B),
      jerseyPrimary: Color(0xFF10B981),
      jerseySecondary: Color(0xFF047857),
      skinColor: Color(0xFFE8B88A),
      hairColor: Color(0xFF292524),
      hairStyle: FootballerHairStyle.shortModern,
      accessory: FootballerAccessory.keeperGloves,
    ),
    FootballerAvatarPreset(
      id: 'pirlo_21',
      name: 'Maestro #21',
      roleLabel: 'Orta Saha Profesörü',
      jerseyNumber: '21',
      bgPrimary: Color(0xFF1E3A8A),
      bgSecondary: Color(0xFF0F172A),
      jerseyPrimary: Color(0xFF2563EB),
      jerseySecondary: Color(0xFFFFFFFF),
      skinColor: Color(0xFFF1C27D),
      hairColor: Color(0xFF3F271E),
      hairStyle: FootballerHairStyle.longMaestro,
      accessory: FootballerAccessory.beard,
    ),
    FootballerAvatarPreset(
      id: 'tactician',
      name: 'Kurt Hoca',
      roleLabel: 'Taktik Dehası',
      jerseyNumber: 'TD',
      bgPrimary: Color(0xFF1F2937),
      bgSecondary: Color(0xFF111827),
      jerseyPrimary: Color(0xFF1E293B),
      jerseySecondary: Color(0xFFEF4444),
      skinColor: Color(0xFFE5B887),
      hairColor: Color(0xFF9CA3AF),
      hairStyle: FootballerHairStyle.classicParted,
      accessory: FootballerAccessory.tacticalSuit,
    ),
    FootballerAvatarPreset(
      id: 'golden_ball',
      name: 'Altın İkon #99',
      roleLabel: 'Ballon d\'Or Efsanesi',
      jerseyNumber: '99',
      bgPrimary: Color(0xFF451A03),
      bgSecondary: Color(0xFF1C0A00),
      jerseyPrimary: Color(0xFFF59E0B),
      jerseySecondary: Color(0xFF18181B),
      skinColor: Color(0xFFC68642),
      hairColor: Color(0xFF18181B),
      hairStyle: FootballerHairStyle.spikyFade,
      accessory: FootballerAccessory.goldCrown,
    ),
  ];

  static FootballerAvatarPreset resolve(String avatarKey) {
    final normalized = avatarKey.trim();
    for (final preset in presets) {
      if (preset.id == normalized) return preset;
    }

    // Legacy 2-letter code mapping so existing users and bots get distinct footballer portraits
    switch (normalized.toUpperCase()) {
      case 'KP':
      case 'HG':
      case 'SN':
        return presets[0]; // Leo #10
      case 'CR':
      case 'ST':
        return presets[1]; // Ronaldo #7
      case 'MH':
      case 'GS':
        return presets[2]; // Kral #9
      case 'SC':
      case 'CN':
        return presets[3]; // Harika Çocuk #19
      case 'SK':
      case 'AH':
        return presets[4]; // Kaptan #10
      case 'KK':
      case 'DF':
      case 'BK':
        return presets[5]; // Kara Kartal #4
      case 'PM':
      case 'BT':
        return presets[6]; // Sambacı #11
      case 'CZ':
      case 'GN':
        return presets[7]; // Viking #9
      case 'GK':
      case 'KL':
        return presets[8]; // Panter #1
      case 'OR':
      case 'KM':
        return presets[9]; // Maestro #21
      case 'TR':
        return presets[10]; // Kurt Hoca
      default:
        final hash = normalized.codeUnits.fold<int>(0, (a, b) => a + b);
        return presets[hash % presets.length];
    }
  }
}

class PlayerAvatarWidget extends StatelessWidget {
  final String avatarKey;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final bool showJerseyBadge;

  const PlayerAvatarWidget({
    super.key,
    required this.avatarKey,
    this.size = 44,
    this.borderColor,
    this.borderWidth = 1.4,
    this.showJerseyBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final preset = PlayerAvatarRegistry.resolve(avatarKey);
    final effectiveBorder = borderColor ?? AppColors.pitchGreen;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            preset.bgPrimary,
            preset.bgSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: effectiveBorder,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _FootballerPortraitPainter(preset: preset),
            ),
            if (showJerseyBadge && size >= 34)
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size * 0.08,
                    vertical: size * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.7),
                      width: 0.7,
                    ),
                  ),
                  child: Text(
                    preset.jerseyNumber,
                    style: TextStyle(
                      fontSize: (size * 0.19).clamp(7.5, 11.0),
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                      height: 1.05,
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

class _FootballerPortraitPainter extends CustomPainter {
  final FootballerAvatarPreset preset;

  _FootballerPortraitPainter({required this.preset});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Subtle stadium spotlight glow behind the footballer
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          preset.jerseyPrimary.withValues(alpha: 0.28),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.5, h * 0.42), radius: w * 0.52));
    canvas.drawCircle(Offset(w * 0.5, h * 0.42), w * 0.52, glowPaint);

    // 1. Shoulders & Football Jersey
    final jerseyPath = Path()
      ..moveTo(w * 0.12, h * 1.02)
      ..quadraticBezierTo(w * 0.16, h * 0.68, w * 0.35, h * 0.66)
      ..lineTo(w * 0.65, h * 0.66)
      ..quadraticBezierTo(w * 0.84, h * 0.68, w * 0.88, h * 1.02)
      ..close();

    final jerseyPaint = Paint()..color = preset.jerseyPrimary;
    canvas.drawPath(jerseyPath, jerseyPaint);

    // Jersey Stripes / Pattern
    canvas.save();
    canvas.clipPath(jerseyPath);
    final stripePaint = Paint()..color = preset.jerseySecondary;

    if (preset.accessory == FootballerAccessory.tacticalSuit) {
      // Shirt & Tie for Coach
      final shirtPath = Path()
        ..moveTo(w * 0.42, h * 0.66)
        ..lineTo(w * 0.58, h * 0.66)
        ..lineTo(w * 0.50, h * 0.95)
        ..close();
      canvas.drawPath(shirtPath, Paint()..color = Colors.white);
      final tiePath = Path()
        ..moveTo(w * 0.48, h * 0.68)
        ..lineTo(w * 0.52, h * 0.68)
        ..lineTo(w * 0.53, h * 0.92)
        ..lineTo(w * 0.50, h * 0.97)
        ..lineTo(w * 0.47, h * 0.92)
        ..close();
      canvas.drawPath(tiePath, stripePaint);
    } else {
      // Classic vertical stripes on jersey
      canvas.drawRect(Rect.fromLTWH(w * 0.28, h * 0.65, w * 0.10, h * 0.40), stripePaint);
      canvas.drawRect(Rect.fromLTWH(w * 0.62, h * 0.65, w * 0.10, h * 0.40), stripePaint);
    }

    // Captain Armband if applicable
    if (preset.accessory == FootballerAccessory.captainBand) {
      canvas.drawRect(
        Rect.fromLTWH(w * 0.14, h * 0.78, w * 0.14, h * 0.08),
        Paint()..color = AppColors.gold,
      );
    }
    canvas.restore();

    // Jersey V-Neck Collar
    final collarPaint = Paint()
      ..color = preset.jerseySecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;
    final collarPath = Path()
      ..moveTo(w * 0.37, h * 0.66)
      ..lineTo(w * 0.50, h * 0.76)
      ..lineTo(w * 0.63, h * 0.66);
    canvas.drawPath(collarPath, collarPaint);

    // 2. Neck
    final skinPaint = Paint()..color = preset.skinColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.50, h * 0.62), width: w * 0.18, height: h * 0.16),
        Radius.circular(w * 0.05),
      ),
      skinPaint,
    );

    // 3. Ears
    canvas.drawCircle(Offset(w * 0.29, h * 0.44), w * 0.05, skinPaint);
    canvas.drawCircle(Offset(w * 0.71, h * 0.44), w * 0.05, skinPaint);

    // 4. Head / Face
    final headRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.43),
      width: w * 0.42,
      height: h * 0.44,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, Radius.circular(w * 0.18)),
      skinPaint,
    );

    // 5. Beard if applicable
    if (preset.accessory == FootballerAccessory.beard ||
        preset.id == 'goat_10' ||
        preset.id == 'pirlo_21' ||
        preset.id == 'icardi_9') {
      final beardPaint = Paint()
        ..color = preset.id == 'icardi_9'
            ? const Color(0xFF3A2A1D).withValues(alpha: 0.75)
            : preset.hairColor.withValues(alpha: 0.85);
      final beardPath = Path()
        ..moveTo(w * 0.31, h * 0.48)
        ..quadraticBezierTo(w * 0.50, h * 0.68, w * 0.69, h * 0.48)
        ..quadraticBezierTo(w * 0.66, h * 0.63, w * 0.50, h * 0.64)
        ..quadraticBezierTo(w * 0.34, h * 0.63, w * 0.31, h * 0.48)
        ..close();
      canvas.drawPath(beardPath, beardPaint);
    }

    // 6. Eyes, Eyebrows & Confident Smile
    final eyePaint = Paint()..color = const Color(0xFF1E1B18);
    canvas.drawCircle(Offset(w * 0.41, h * 0.42), w * 0.026, eyePaint);
    canvas.drawCircle(Offset(w * 0.59, h * 0.42), w * 0.026, eyePaint);

    final browPaint = Paint()
      ..color = preset.hairColor
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.37, h * 0.375), Offset(w * 0.45, h * 0.38), browPaint);
    canvas.drawLine(Offset(w * 0.55, h * 0.38), Offset(w * 0.63, h * 0.375), browPaint);

    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.50), width: w * 0.14, height: h * 0.07),
      0.15,
      2.8,
      false,
      smilePaint,
    );

    // 7. Hair Styles
    final hairPaint = Paint()..color = preset.hairColor;
    switch (preset.hairStyle) {
      case FootballerHairStyle.spikyFade:
        final spikyPath = Path()
          ..moveTo(w * 0.29, h * 0.36)
          ..lineTo(w * 0.34, h * 0.21)
          ..lineTo(w * 0.42, h * 0.25)
          ..lineTo(w * 0.50, h * 0.17)
          ..lineTo(w * 0.58, h * 0.24)
          ..lineTo(w * 0.66, h * 0.20)
          ..lineTo(w * 0.71, h * 0.36)
          ..quadraticBezierTo(w * 0.50, h * 0.29, w * 0.29, h * 0.36)
          ..close();
        canvas.drawPath(spikyPath, hairPaint);
        break;

      case FootballerHairStyle.bleachedBlonde:
      case FootballerHairStyle.shortModern:
      case FootballerHairStyle.classicParted:
        final hairPath = Path()
          ..moveTo(w * 0.28, h * 0.38)
          ..quadraticBezierTo(w * 0.28, h * 0.19, w * 0.50, h * 0.19)
          ..quadraticBezierTo(w * 0.72, h * 0.19, w * 0.72, h * 0.38)
          ..quadraticBezierTo(w * 0.52, h * 0.29, w * 0.28, h * 0.38)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        break;

      case FootballerHairStyle.curlyHeadband:
        canvas.drawCircle(Offset(w * 0.36, h * 0.26), w * 0.09, hairPaint);
        canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.10, hairPaint);
        canvas.drawCircle(Offset(w * 0.64, h * 0.26), w * 0.09, hairPaint);
        // Headband
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.29, h * 0.29, w * 0.42, h * 0.055),
            Radius.circular(w * 0.02),
          ),
          Paint()..color = preset.jerseyPrimary,
        );
        break;

      case FootballerHairStyle.longBand:
      case FootballerHairStyle.longMaestro:
        // Long flowing hair behind and on top
        final longHair = Path()
          ..moveTo(w * 0.24, h * 0.56)
          ..quadraticBezierTo(w * 0.23, h * 0.18, w * 0.50, h * 0.18)
          ..quadraticBezierTo(w * 0.77, h * 0.18, w * 0.76, h * 0.56)
          ..lineTo(w * 0.69, h * 0.56)
          ..lineTo(w * 0.69, h * 0.34)
          ..quadraticBezierTo(w * 0.50, h * 0.28, w * 0.31, h * 0.34)
          ..lineTo(w * 0.31, h * 0.56)
          ..close();
        canvas.drawPath(longHair, hairPaint);
        if (preset.hairStyle == FootballerHairStyle.longBand) {
          canvas.drawRect(
            Rect.fromLTWH(w * 0.29, h * 0.30, w * 0.42, h * 0.04),
            Paint()..color = const Color(0xFF0284C7),
          );
        }
        break;

      case FootballerHairStyle.buzzCut:
        final buzzPath = Path()
          ..moveTo(w * 0.30, h * 0.35)
          ..quadraticBezierTo(w * 0.32, h * 0.22, w * 0.50, h * 0.22)
          ..quadraticBezierTo(w * 0.68, h * 0.22, w * 0.70, h * 0.35)
          ..quadraticBezierTo(w * 0.50, h * 0.30, w * 0.30, h * 0.35)
          ..close();
        canvas.drawPath(buzzPath, hairPaint);
        break;
    }

    // 8. Special Accessories (Crown or Goalkeeper Gloves)
    if (preset.accessory == FootballerAccessory.goldCrown) {
      final crownPaint = Paint()..color = AppColors.gold;
      final crownPath = Path()
        ..moveTo(w * 0.36, h * 0.20)
        ..lineTo(w * 0.39, h * 0.10)
        ..lineTo(w * 0.45, h * 0.16)
        ..lineTo(w * 0.50, h * 0.08)
        ..lineTo(w * 0.55, h * 0.16)
        ..lineTo(w * 0.61, h * 0.10)
        ..lineTo(w * 0.64, h * 0.20)
        ..close();
      canvas.drawPath(crownPath, crownPaint);
    } else if (preset.accessory == FootballerAccessory.keeperGloves) {
      // Raised goalkeeper glove badge on left side
      final glovePaint = Paint()..color = AppColors.gold;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.14, h * 0.58, w * 0.14, h * 0.16),
          Radius.circular(w * 0.04),
        ),
        glovePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FootballerPortraitPainter oldDelegate) {
    return oldDelegate.preset.id != preset.id;
  }
}
