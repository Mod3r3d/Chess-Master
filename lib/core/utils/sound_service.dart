import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool soundEnabled = true;
  bool hapticEnabled = true;

  void playMoveSound() {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.click);
    if (hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void playCaptureSound() {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.click);
    if (hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void playCheckSound() {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
    if (hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  void playGameEndSound({bool isWin = true}) {
    if (!soundEnabled) return;
    SystemSound.play(SystemSoundType.alert);
    if (hapticEnabled) {
      HapticFeedback.vibrate();
    }
  }
}
