import 'package:flutter/services.dart';

class GameFeedback {
  /// Vibration tick for 3-2-1 countdown and ticking timer
  static void tick() {
    HapticFeedback.selectionClick();
  }

  /// Heavy impact for bomb explosion or time out
  static void explode() {
    HapticFeedback.heavyImpact();
  }

  /// Success impact for correct answer
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Error buzz for wrong answer
  static void error() {
    HapticFeedback.vibrate();
  }
}
