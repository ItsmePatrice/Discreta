import 'dart:io';
import 'package:vibration/vibration.dart';

class VibrationService {
  static Future<void> confirmation() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;

    if (Platform.isIOS) {
      // iOS only supports single vibration — trigger twice manually
      await Vibration.vibrate();
      await Future.delayed(const Duration(milliseconds: 600));
      await Vibration.vibrate();
    } else {
      await Vibration.vibrate(pattern: [0, 500, 100, 500]);
    }
  }
}
