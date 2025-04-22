import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'text_to_speech.dart';
import 'package:echoquest/utils/sound_helper.dart';

class VoiceInput {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _shouldStopListening = false;
  static bool _isListening = false;
  static bool _initialized = false;

  /// Initialize the speech recognizer (only once)
  static Future<void> initialize() async {
    if (_initialized) return;

    bool available = await _speech.initialize(
      onStatus: (status) => print("VoiceInput Init Status: $status"),
      onError: (error) => print("VoiceInput Init Error: $error"),
    );

    if (!available) {
      print("VoiceInput: Initialization failed.");
    } else {
      _initialized = true;
      print("VoiceInput: Successfully initialized.");
    }
  }

  /// Start listening and return the recognized text
  static Future<String> listen() async {
    if (TextToSpeech.isSpeaking) {
      print("VoiceInput: Skipping listening because TTS is speaking.");
      return "";
    }

    print('VoiceInput: Starting speech recognition...');
    await initialize();

    _shouldStopListening = false;
    _isListening = true;
    String recognizedWords = "";
    Completer<void> completer = Completer<void>();

    // ✅ Mic ON Beep
    try {
      SoundHelper.playMicSound();
      print("VoiceInput: Mic ON ********************************MIC ON**********************************");
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print("VoiceInput: Mic ON beep error - $e");
    }

    // Start listening
    _speech.listen(
      onResult: (result) {
        if (!_shouldStopListening) {
          recognizedWords = result.recognizedWords;
          print("VoiceInput: Recognized: $recognizedWords");
        }
      },
      listenMode: stt.ListenMode.confirmation,
    );

    // Stop listening when done
    _speech.statusListener = (status) async {
      print("VoiceInput: Status changed: $status");
      if (status == 'done' || _shouldStopListening) {
        // ✅ Mic OFF Beep
        try {
          await SoundHelper.playMicSound();
        } catch (e) {
          print("VoiceInput: Mic OFF beep error - $e");
        }

        if (!completer.isCompleted) completer.complete();
      }
    };

    // Timeout fallback
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print("VoiceInput: Timed out.");
        _speech.stop();
      },
    );

    _speech.stop();
    _isListening = false;

    if (_shouldStopListening) {
      print("VoiceInput: Manually stopped.");
      return "";
    }

    return recognizedWords.trim();
  }

  /// Forcefully stop listening
  static void stopListening() {
    print("VoiceInput: Force stopping...");
    _shouldStopListening = true;
    if (_speech.isListening) _speech.stop();
    _isListening = false;
  }

  static bool get isListening => _isListening;
}
