import 'package:audioplayers/audioplayers.dart';

class AudioFeedback {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playListeningSound() async {
    await _player.play(AssetSource('lib/sounds/mic_on.wav')); // Ensure the file exists
  }

  static Future<void> playStopListeningSound() async {
    await _player.play(AssetSource('lib/sounds/mic_on.wav')); // Ensure the file exists
  }
}
