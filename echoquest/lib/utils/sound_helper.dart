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
import 'package:flutter/foundation.dart' show kIsWeb;

class SoundHelper {

  static dynamic _webBeep; // Use dynamic to avoid dart:html on non-web

  /// ✅ Call this once at app start (e.g. in main.dart)
  static Future<void> preloadBeepSound() async {
    if (kIsWeb) {
      // Avoid importing dart:html directly in mobile builds
      _webBeep = createWebAudioElement();
      _webBeep?.preload = 'auto';
      _webBeep?.load();
    }
  }

  /// ✅ Play mic sound depending on platform
  static Future<void> playMicSound() async {
    if (kIsWeb) {
      try {
        _webBeep?.currentTime = 0;
        _webBeep?.play();
      } catch (e) {
        print("Web audio beep error: $e");
      }
    } else {
      final player = AudioPlayer();
      await player.play(AssetSource('assets/mic_on.wav'));
    }
  }

  static dynamic createWebAudioElement() {
    if (kIsWeb) {
      // This block only executes on Web, so dart:html is safe
      return Function.apply(
        (uri) => (Uri uri) => throw UnimplementedError(), // dummy
        [],
        {
          #uri: Uri.parse('assets/mic_on.wav'),
        },
      ); // this avoids web import on other platforms
    }
    return null;
  }

}

