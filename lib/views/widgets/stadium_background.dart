import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StadiumBackground extends StatefulWidget {
  final Widget child;
  final bool showFieldLines;
  final bool showLiveMatch;

  const StadiumBackground({
    super.key,
    required this.child,
    this.showFieldLines = true,
    this.showLiveMatch = true,
  });

  @override
  State<StadiumBackground> createState() => _StadiumBackgroundState();
}

class _StadiumBackgroundState extends State<StadiumBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _matchController;

  @override
  void initState() {
    super.initState();
    _matchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 18000),
    )..repeat();
  }

  @override
  void dispose() {
    _matchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF061A12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Football Pitch Lawn Mowing Bands & Micro-Turf Texture
          Positioned.fill(
            child: CustomPaint(
              painter: _FootballPitchBasePainter(),
            ),
          ),

          // 2. Realistic Tactical Pitch Markings, Stadium Floodlights & Live Match Simulation
          if (widget.showFieldLines)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _matchController,
                builder: (context, _) {
                  final progress = _matchController.value;
                  final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
                  return CustomPaint(
                    painter: _TacticalFieldLinesPainter(
                      pulseProgress: pulse,
                      matchProgress: progress,
                      showLiveMatch: widget.showLiveMatch,
                    ),
                  );
                },
              ),
            ),

          // 3. Balanced Vignette Overlay for UI Contrast while keeping live match visible
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF04120C).withValues(alpha: 0.32),
                      const Color(0xFF061B13).withValues(alpha: 0.12),
                      const Color(0xFF05160F).withValues(alpha: 0.28),
                      const Color(0xFF030D09).withValues(alpha: 0.58),
                    ],
                    stops: const [0.0, 0.35, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 4. Foreground Content
          SafeArea(child: widget.child),
        ],
      ),
    );
  }
}

/// Paints the alternating cut turf lawn pattern of an elite football stadium pitch
class _FootballPitchBasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Rich nocturnal stadium grass stripes
    const darkStripe = Color(0xFF072217);
    const lightStripe = Color(0xFF0B2C1E);

    const stripeHeight = 58.0;
    final count = (height / stripeHeight).ceil() + 1;

    for (int i = 0; i < count; i++) {
      final y = i * stripeHeight;
      final paint = Paint()
        ..color = (i % 2 == 0) ? lightStripe : darkStripe
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, y, width, stripeHeight), paint);
    }

    // Subtle vertical grass mowing sheen lines
    final sheenPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.025)
      ..strokeWidth = 1.0;
    for (double x = 24; x < width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), sheenPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SimPlayerSpec {
  final int index;
  final bool isHome;
  final String number;
  final double baseX;
  final double baseY;
  final bool isGoalkeeper;

  const _SimPlayerSpec({
    required this.index,
    required this.isHome,
    required this.number,
    required this.baseX,
    required this.baseY,
    this.isGoalkeeper = false,
  });
}

class _PlayEvent {
  final int fromPlayer;
  final int toPlayer;
  final bool isShot;

  const _PlayEvent({
    required this.fromPlayer,
    required this.toPlayer,
    this.isShot = false,
  });
}

/// Paints authentic stadium chalk lines + live animated 6v6 football match on the pitch
class _TacticalFieldLinesPainter extends CustomPainter {
  final double pulseProgress;
  final double matchProgress;
  final bool showLiveMatch;

  _TacticalFieldLinesPainter({
    required this.pulseProgress,
    required this.matchProgress,
    required this.showLiveMatch,
  });

  // 0..5: Home team (Emerald/Neon Green, attacking UP toward top goal)
  // 6..11: Away team (Gold/Amber, attacking DOWN toward bottom goal)
  static const List<_SimPlayerSpec> _players = [
    // Home Team
    _SimPlayerSpec(index: 0, isHome: true, number: '1', baseX: 0.50, baseY: 0.91, isGoalkeeper: true),
    _SimPlayerSpec(index: 1, isHome: true, number: '4', baseX: 0.24, baseY: 0.74),
    _SimPlayerSpec(index: 2, isHome: true, number: '5', baseX: 0.76, baseY: 0.72),
    _SimPlayerSpec(index: 3, isHome: true, number: '8', baseX: 0.45, baseY: 0.55),
    _SimPlayerSpec(index: 4, isHome: true, number: '10', baseX: 0.20, baseY: 0.36),
    _SimPlayerSpec(index: 5, isHome: true, number: '9', baseX: 0.56, baseY: 0.22),
    // Away Team
    _SimPlayerSpec(index: 6, isHome: false, number: '1', baseX: 0.50, baseY: 0.09, isGoalkeeper: true),
    _SimPlayerSpec(index: 7, isHome: false, number: '2', baseX: 0.75, baseY: 0.26),
    _SimPlayerSpec(index: 8, isHome: false, number: '4', baseX: 0.27, baseY: 0.28),
    _SimPlayerSpec(index: 9, isHome: false, number: '6', baseX: 0.55, baseY: 0.46),
    _SimPlayerSpec(index: 10, isHome: false, number: '7', baseX: 0.80, baseY: 0.63),
    _SimPlayerSpec(index: 11, isHome: false, number: '11', baseX: 0.43, baseY: 0.78),
  ];

  // 10-step continuous match sequence: Home build-up & shot -> Away save & counter-attack -> Home save
  static const List<_PlayEvent> _sequence = [
    _PlayEvent(fromPlayer: 0, toPlayer: 1), // GK out to Left Back
    _PlayEvent(fromPlayer: 1, toPlayer: 3), // Left Back to #8 Maestro
    _PlayEvent(fromPlayer: 3, toPlayer: 4), // Through pass to #10 Left Wing
    _PlayEvent(fromPlayer: 4, toPlayer: 5), // Cross into box to #9 Striker
    _PlayEvent(fromPlayer: 5, toPlayer: 6, isShot: true), // #9 shoots, Away GK saves
    _PlayEvent(fromPlayer: 6, toPlayer: 7), // Away GK throws to Right Back
    _PlayEvent(fromPlayer: 7, toPlayer: 9), // Right Back to #6 Midfielder
    _PlayEvent(fromPlayer: 9, toPlayer: 10), // Wide pass to #7 Right Wing
    _PlayEvent(fromPlayer: 10, toPlayer: 11), // Cutback to #11 Away Striker
    _PlayEvent(fromPlayer: 11, toPlayer: 0, isShot: true), // #11 shoots, Home GK saves
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final lineAlpha = 0.15 + pulseProgress * 0.04;
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: lineAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final glowPaint = Paint()
      ..color = AppColors.pitchGreen.withValues(alpha: 0.07 + pulseProgress * 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final spotPaint = Paint()
      ..color = Colors.white.withValues(alpha: lineAlpha * 1.4)
      ..style = PaintingStyle.fill;

    // Outer pitch boundary (touchlines & goal lines)
    const marginX = 10.0;
    const marginY = 8.0;
    final pitchWidth = width - marginX * 2;
    final pitchHeight = height - marginY * 2;
    final pitchRect = Rect.fromLTWH(marginX, marginY, pitchWidth, pitchHeight);
    canvas.drawRect(pitchRect, linePaint);

    // Halfway line & Center circle
    final centerY = height * 0.50;
    final centerCircleRadius = width * 0.23;
    final center = Offset(width * 0.5, centerY);

    canvas.drawLine(Offset(marginX, centerY), Offset(width - marginX, centerY), linePaint);
    canvas.drawCircle(center, centerCircleRadius, glowPaint);
    canvas.drawCircle(center, centerCircleRadius, linePaint);
    canvas.drawCircle(center, 3.5, spotPaint);

    // Top 18-yard Penalty Box & 6-yard Goal Box
    final boxWidth = pitchWidth * 0.62;
    final boxHeight = pitchHeight * 0.15;
    final boxLeft = marginX + (pitchWidth - boxWidth) / 2;
    canvas.drawRect(Rect.fromLTWH(boxLeft, marginY, boxWidth, boxHeight), linePaint);

    final goalBoxWidth = pitchWidth * 0.30;
    final goalBoxHeight = boxHeight * 0.42;
    final goalBoxLeft = marginX + (pitchWidth - goalBoxWidth) / 2;
    canvas.drawRect(Rect.fromLTWH(goalBoxLeft, marginY, goalBoxWidth, goalBoxHeight), linePaint);

    // Top Penalty Spot & Penalty Arc
    canvas.drawCircle(Offset(width * 0.5, marginY + boxHeight * 0.72), 2.5, spotPaint);
    final topArcRect = Rect.fromCircle(
      center: Offset(width * 0.5, marginY + boxHeight * 0.72),
      radius: pitchWidth * 0.13,
    );
    canvas.drawArc(topArcRect, 0.35, math.pi - 0.70, false, linePaint);

    // Bottom 18-yard Penalty Box, 6-yard Goal Box & Arc
    final bottomBoxTop = height - marginY - boxHeight;
    canvas.drawRect(Rect.fromLTWH(boxLeft, bottomBoxTop, boxWidth, boxHeight), linePaint);
    canvas.drawRect(
      Rect.fromLTWH(goalBoxLeft, height - marginY - goalBoxHeight, goalBoxWidth, goalBoxHeight),
      linePaint,
    );
    canvas.drawCircle(Offset(width * 0.5, bottomBoxTop + boxHeight * 0.28), 2.5, spotPaint);
    final bottomArcRect = Rect.fromCircle(
      center: Offset(width * 0.5, bottomBoxTop + boxHeight * 0.28),
      radius: pitchWidth * 0.13,
    );
    canvas.drawArc(bottomArcRect, math.pi + 0.35, math.pi - 0.70, false, linePaint);

    // Corner Arcs
    const cornerR = 18.0;
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(marginX, marginY), radius: cornerR),
      0,
      math.pi / 2,
      false,
      linePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(width - marginX, marginY), radius: cornerR),
      math.pi / 2,
      math.pi / 2,
      false,
      linePaint,
    );

    // Live Match Simulation (Players running, passing, shooting)
    if (showLiveMatch) {
      _paintLiveMatch(canvas, pitchRect);
    }

    // Twin Stadium Floodlights (Top-Left & Top-Right)
    final leftLight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.85, -0.95),
        radius: 1.1,
        colors: [
          const Color(0xFF34D399).withValues(alpha: 0.10 + pulseProgress * 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height * 0.55));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height * 0.55), leftLight);

    final rightLight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.85, -0.95),
        radius: 1.1,
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.06 + pulseProgress * 0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height * 0.55));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height * 0.55), rightLight);
  }

  void _paintLiveMatch(Canvas canvas, Rect pitchRect) {
    final totalSteps = _sequence.length;
    final scaled = (matchProgress * totalSteps) % totalSteps;
    final stepIndex = scaled.floor().clamp(0, totalSteps - 1);
    final stepLocalT = scaled - stepIndex;
    final event = _sequence[stepIndex];

    // Collective team shift based on who is attacking (steps 0..4 Home attacks UP, steps 5..9 Away attacks DOWN)
    final attackWave = math.sin(matchProgress * math.pi * 2); // +1 when Home attacks, -1 when Away attacks

    // Compute live positions of all 12 players
    final List<Offset> positions = List<Offset>.generate(_players.length, (i) {
      final spec = _players[i];
      final phaseAngle = matchProgress * math.pi * 4 + i * 1.15;

      double nx = spec.baseX;
      double ny = spec.baseY;

      if (spec.isGoalkeeper) {
        // Goalkeepers patrol laterally along the goal line
        nx += math.sin(matchProgress * math.pi * 2 + (spec.isHome ? 0.4 : 2.1)) * 0.06;
        ny += math.cos(phaseAngle) * 0.008;
      } else {
        // Outfield players make realistic attacking & defending runs
        final shiftY = -attackWave * 0.055;
        final roamX = math.sin(phaseAngle) * 0.045;
        final roamY = math.cos(phaseAngle * 1.5) * 0.035;
        nx = (spec.baseX + roamX).clamp(0.08, 0.92);
        ny = (spec.baseY + shiftY + roamY).clamp(0.11, 0.89);
      }

      return Offset(
        pitchRect.left + nx * pitchRect.width,
        pitchRect.top + ny * pitchRect.height,
      );
    });

    final fromPos = positions[event.fromPlayer];
    final toPos = positions[event.toPlayer];

    // First 30% of each step: player dribbles/prepares; remaining 70%: ball travels to target player
    final double passT = stepLocalT < 0.26
        ? 0.0
        : Curves.easeInOutCubic.transform(((stepLocalT - 0.26) / 0.74).clamp(0.0, 1.0));

    final ballPos = Offset.lerp(fromPos, toPos, passT)!;

    // Draw subtle tactical pass trajectory line while ball is in flight
    if (passT > 0.02 && passT < 0.96) {
      final passColor = event.isShot
          ? AppColors.gold.withValues(alpha: 0.42)
          : AppColors.greenLight.withValues(alpha: 0.28);
      _drawDashedLine(canvas, ballPos, toPos, passColor);
    }

    // Draw each footballer on the pitch
    for (int i = 0; i < _players.length; i++) {
      final spec = _players[i];
      final pos = positions[i];
      final hasBall = (passT < 0.18 && i == event.fromPlayer) ||
          (passT > 0.85 && i == event.toPlayer);

      // Soft turf shadow under player
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: pos.translate(0, 5.5), width: 14, height: 6),
        shadowPaint,
      );

      // Active ball-carrier radar ring
      if (hasBall) {
        final ringPaint = Paint()
          ..color = (spec.isHome ? AppColors.greenLight : AppColors.gold)
              .withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(pos, 11.5, ringPaint);
      }

      // Jersey body circle
      final jerseyColor = spec.isGoalkeeper
          ? (spec.isHome ? const Color(0xFF0EA5E9) : const Color(0xFFEC4899))
          : (spec.isHome ? const Color(0xFF10B981) : const Color(0xFFF59E0B));

      final bodyPaint = Paint()
        ..color = jerseyColor.withValues(alpha: 0.72)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 7.2, bodyPaint);

      // Crisp white tactical ring around player marker
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(pos, 7.2, borderPaint);

      // Jersey number
      final textPainter = TextPainter(
        text: TextSpan(
          text: spec.number,
          style: TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w900,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }

    // Draw the moving Football + glow trail
    if (passT > 0.05 && passT < 0.95) {
      final trailStart = Offset.lerp(fromPos, ballPos, 0.55)!;
      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            (event.isShot ? AppColors.gold : Colors.white).withValues(alpha: 0.55),
          ],
        ).createShader(Rect.fromPoints(trailStart, ballPos))
        ..strokeWidth = event.isShot ? 3.2 : 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(trailStart, ballPos, trailPaint);
    }

    // Ball shadow
    canvas.drawCircle(
      ballPos.translate(1.2, 2.2),
      4.0,
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
    // Ball outer glow
    canvas.drawCircle(
      ballPos,
      6.5,
      Paint()
        ..color = (event.isShot ? AppColors.gold : Colors.white).withValues(alpha: 0.28),
    );
    // Ball core
    canvas.drawCircle(
      ballPos,
      3.8,
      Paint()..color = Colors.white,
    );
    // Ball center pentagon dot
    canvas.drawCircle(
      ballPos,
      1.5,
      Paint()..color = const Color(0xFF0F172A),
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final distance = (end - start).distance;
    if (distance <= 1) return;
    const dashLength = 5.0;
    const gapLength = 4.0;
    final dir = (end - start) / distance;
    double current = 0;
    while (current < distance) {
      final p1 = start + dir * current;
      final p2 = start + dir * math.min(current + dashLength, distance);
      canvas.drawLine(p1, p2, paint);
      current += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _TacticalFieldLinesPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.matchProgress != matchProgress ||
        oldDelegate.showLiveMatch != showLiveMatch;
  }
}
