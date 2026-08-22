import 'dart:io';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

class VibrationService {
  static Future<void> confirmation() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;

    if (Platform.isIOS) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 400));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 400));
      await HapticFeedback.heavyImpact();
    } else {
      await Vibration.vibrate(pattern: [0, 500, 100, 500]);
    }
  }

  static Future<void> appRunningconfirmation() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;

    if (Platform.isIOS) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 400));
      await HapticFeedback.heavyImpact();
    } else {
      await Vibration.vibrate(pattern: [0, 500]);
    }
  }
}
