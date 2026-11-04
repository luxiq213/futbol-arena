import 'package:flutter/material.dart';

class AppColors {
  // Strict Night Navy & Pitch Theme
  static const Color background = Color(0xFF080E1E);
  static const Color backgroundSecondary = Color(0xFF0D172E);
  static const Color surface = Color(0xFF142038);
  static const Color surfaceLight = Color(0xFF1E2D4A);
  
  // Secondary Accent: Football Pitch Green / Emerald (Replacing Purple)
  static const Color pitchGreen = Color(0xFF10B981);
  static const Color greenLight = Color(0xFF34D399);
  static const Color darkGreen = Color(0xFF064E3B);
  static const Color emerald = Color(0xFF059669);

  // Backward compatibility alias: deepPurple now maps to pitchGreen
  static const Color deepPurple = pitchGreen;
  static const Color purpleLight = greenLight;
  
  // Gold & Metallic Accents
  static const Color gold = Color(0xFFFFD700);
  static const Color goldMuted = Color(0xFFD4AF37);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color lavender = Color(0xFFC8A2C8);
  static const Color deepBlue = Color(0xFF1E3A8A);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF64748B);
  
  // Clean Linear Borders
  static const Color border = Color(0x29CBD5E1);
  static const Color borderActive = Color(0x6610B981);
  static const Color borderGreen = Color(0x4410B981);
  static const Color borderPurple = borderGreen;
}
