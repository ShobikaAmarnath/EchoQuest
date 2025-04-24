import 'package:flutter_tts/flutter_tts.dart';
class TextToSpeech {
  static final FlutterTts _tts = FlutterTts();
  static bool isSpeaking = false;

  static Future<void> _configureTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setVoice({"name" : "en-us-SMTf00", "locale" : "eng-x-lvariant-f00"});
    await _tts.setPitch(1.1);
    await _tts.setSpeechRate(0.43);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
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
      if (isSpeaking) {
        await _tts.stop();
        isSpeaking = false;
      }
      if (sentence.trim().isNotEmpty) {
        await speak(sentence.trim());
        await Future.delayed(Duration(milliseconds: 700));
      }
    }
  }

  static Future<void> stop() async {
    await _tts.stop();
    isSpeaking = false;
  }
}
