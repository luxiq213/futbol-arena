import 'package:flutter/material.dart';

class AppColors {
  // Stadium Pitch Palette
  static const Color background = Color(0xFF061410);
  static const Color backgroundSecondary = Color(0xFF091C17);
  static const Color surface = Color(0xFF0F261F);
  static const Color surfaceLight = Color(0xFF18382E);
  
  // Tactical Pitch Green & Grass Accents
  static const Color pitchGreen = Color(0xFF10B981);
  static const Color greenLight = Color(0xFF34D399);
  static const Color darkGreen = Color(0xFF064E3B);
  static const Color emerald = Color(0xFF059669);
  static const Color grassBlade = Color(0xFF16A34A);

  // Backward compatibility alias: deepPurple now maps to pitchGreen
  static const Color deepPurple = pitchGreen;
  static const Color purpleLight = greenLight;
  
  // Gold & Trophy Accents
  static const Color gold = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFBBF24);
  static const Color goldMuted = Color(0xFFD97706);
  static const Color silver = Color(0xFFCBD5E1);
  static const Color lavender = Color(0xFFC8A2C8);
  static const Color deepBlue = Color(0xFF1E3A8A);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);
  
  // Text Colors (High Contrast)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF7E978F);
  
  // Stadium Line Borders & Chalk Lines
  static const Color border = Color(0x33CBD5E1);
  static const Color borderActive = Color(0x6610B981);
  static const Color borderGreen = Color(0x4410B981);
  static const Color borderPurple = borderGreen;
  static const Color pitchChalkLine = Color(0x2EFFFFFF);
}
