import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:echoquest/utils/progress_tracker.dart';
import 'package:echoquest/utils/text_to_speech.dart';
import 'package:echoquest/utils/voice_input.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'lesson_screen.dart';
import 'chatbot_screen.dart';

class LevelsScreen extends StatefulWidget {
  final String category;

  LevelsScreen({required this.category});

  @override
  _LevelsScreenState createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  bool isListening = false;
  bool isManuallySelected = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isMounted = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _announceInstructions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("Prompt user to listen level called !");
      _promptUser();
      _focusNode.requestFocus(); // Ensure keyboard events are captured
    });
  }
  
  

  @override
  void dispose() {
    isMounted = false;
    _stopAllActions();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _announceInstructions() async {
    await TextToSpeech.speak(
      "Welcome to EchoQuest. Tap the spacebar anytime to talk to Kai, your AI learning companion."
    );
    // await Future.delayed(Duration(seconds: 3));
    // _promptUser();
        
  }

  void _stopAllActions() {
    TextToSpeech.stop();
    VoiceInput.stopListening();
  }

  Future<void> _promptUser() async {
    await TextToSpeech.speak("Choose a level for ${widget.category}, from 1 to 10.");
    await Future.delayed(Duration(seconds: 5));
    if (!isManuallySelected) {
      _listenForLevel();
    }
  }

  void _listenForLevel() async {
    setState(() {
      isListening = true;
    });

    String spokenText = await VoiceInput.listen();

    setState(() {
      isListening = false;
    });

    if (isManuallySelected) return;

    int? level = _extractLevel(spokenText);

    if (level != null && level >= 1 && level <= 10) {
      bool unlocked = await ProgressTracker.isLevelUnlocked(widget.category, level);

      if (unlocked) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonScreen(category: widget.category, level: level),
          ),
        );
      } else {
        await TextToSpeech.speak("Level $level is locked. Score 90% in the previous level to unlock.");
        _promptUser();
      }
    } else {
      await TextToSpeech.speak("I didn't recognize that level. Please try again.");
      _promptUser();
    }
  }

  int? _extractLevel(String spokenText) {
    RegExp numberRegex = RegExp(r'\d+');
    Match? match = numberRegex.firstMatch(spokenText);
    if (match != null) {
      return int.tryParse(match.group(0)!);
    }
    return null;
  }

  void _stopListening() {
    if (isListening) {
      _speech.stop();
      print("stopped speech");
      setState(() {
        isListening = false;
      });
    }
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatBotScreen()),
      );
    }
  }

 @override
Widget build(BuildContext context) {
  return RawKeyboardListener(
    focusNode: _focusNode,
    onKey: _handleKeyPress,
    child: Stack(
      children: [
        // 🔮 Background image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/img/level back.jpg'), // ✅ Ensure this is in your pubspec.yaml
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 📱 Foreground UI with levels
        Scaffold(
          backgroundColor: Colors.transparent, // 👈 Make scaffold transparent
          appBar: AppBar(
            title: Text("Levels - ${widget.category}"),
            backgroundColor: Colors.black.withOpacity(0.7),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    int level = index + 1;
                    return ListTile(
                      title: Text("Level $level"),
                      textColor: Colors.white,
                      onTap: () async {
                        bool unlocked = await ProgressTracker.isLevelUnlocked(widget.category, level);
                        if (unlocked) {
                          isManuallySelected = true;
                          _stopListening();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessonScreen(
                                  category: widget.category, level: level),
                            ),
                          );
                        } else {
                          TextToSpeech.speak(
                              "This level is locked for ${widget.category}. Score 90% in the previous level to unlock.");
                        }
                      },
                    );
                  },
                ),
              ),
              if (isListening)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

}
