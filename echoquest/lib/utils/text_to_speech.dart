import 'package:flutter_tts/flutter_tts.dart';
class TextToSpeech {
  static final FlutterTts _tts = FlutterTts();
  static bool isSpeaking = false;

  static Future<void> _configureTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(1);
    await _tts.setVolume(1.0);
  }

  static Future<void> speak(String text) async {
    await _configureTTS();
    isSpeaking = true;
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(text);
    isSpeaking = false;
  }

  static Future<void> speakParagraph(String paragraph) async {
    List<String> sentences = paragraph.split(RegExp(r'(?<=[.?!])\s+'));
    for (String sentence in sentences) {
      if (sentence.trim().isNotEmpty) {
        await speak(sentence.trim());
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
  }

  static Future<void> stop() async {
    await _tts.stop();
    isSpeaking = false;
  }
}
