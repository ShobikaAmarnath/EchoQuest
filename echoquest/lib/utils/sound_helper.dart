// web

// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:html' as html;

// class SoundHelper {

//   // ignore: unused_field
//   static html.AudioElement? _webBeep;

//   static Future<void> preloadBeepSound() async {
//     if (kIsWeb) {
//       _webBeep = html.AudioElement('assets/sounds/mic_on.mp3')
//         ..preload = 'auto'
//         ..load();
//     }
//   }
//   static Future<void> playMicSound() async {
//     if (kIsWeb) {
//       final audio = html.AudioElement('assets/mic_on.wav');
//       audio.play();
//     } else {
//       final player = AudioPlayer();
//       await player.play(AssetSource('assets/mic_on.wav'));
//     }
//   }
// }

// android

import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> preloadBeepSound() async {
    await _player.setSource(AssetSource('mic_on.mp3'));
  }

  static Future<void> playMicSound() async {
    await _player.stop();
    await _player.play(AssetSource('mic_on.mp3'));
  }
}

