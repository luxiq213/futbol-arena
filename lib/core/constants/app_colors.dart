import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0A0E1A);
  static const Color backgroundSecondary = Color(0xFF131B2E);
  static const Color surface = Color(0xFF1B243B);
  static const Color surfaceLight = Color(0xFF24304F);
  
  // Pitch & Brand Colors
  static const Color pitchGreen = Color(0xFF00E676);
  static const Color pitchGreenDark = Color(0xFF00A854);
  static const Color pitchGreenAccent = Color(0xFF69F0AE);
  
  // Accents & Badges
  static const Color gold = Color(0xFFFFD700);
  static const Color goldAccent = Color(0xFFFFB300);
  static const Color electricBlue = Color(0xFF2979FF);
  static const Color neonPink = Color(0xFFFF1744);
  static const Color crimson = Color(0xFFE53935);
  static const Color orange = Color(0xFFFF9100);
  static const Color purple = Color(0xFF7C4DFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  
  // Glassmorphic borders & highlights
  static const Color cardBorder = Color(0x33475569);
  static const Color cardBorderActive = Color(0x6600E676);
  
  // Gradients
  static const LinearGradient pitchGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00A854)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C2744), Color(0xFF12192C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF7A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF448AFF), Color(0xFF2979FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
