import 'package:vibration/vibration.dart';

class VibrationService {
  static Future<void> confirmation() async {
    final hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator != true) return;

    // Two short vibrations
    await Vibration.vibrate(pattern: [0, 500, 100, 500]);
  }
}
