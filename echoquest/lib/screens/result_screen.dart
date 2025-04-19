import 'package:echoquest/screens/lesson_screen.dart';
import 'package:flutter/material.dart';
import 'package:echoquest/utils/text_to_speech.dart';
import 'package:echoquest/utils/progress_tracker.dart';
import 'package:echoquest/utils/voice_input.dart';
import 'package:echoquest/screens/levels_screen.dart';
import 'package:echoquest/screens/game_screen.dart';
import 'package:echoquest/data/questions.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final String category;
  final int level;
  final int totalQuestions;
  final String lessonContent;
  final List<Question> questions;

  const ResultScreen({
    super.key,
    required this.score,
    required this.category,
    required this.level,
    required this.totalQuestions,
    required this.lessonContent,
    required this.questions,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String feedback;
  late bool isPassed;
  int percentage = 0;
  bool isListening = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _calculateAndSpeakResult();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.logicalKey.keyLabel == ' ') {
        print("Spacebar pressed");
        // You can call a function like _askQuestion() or trigger narration
      }
    }
  }

  Future<void> _calculateAndSpeakResult() async {
    int ts = widget.totalQuestions;

    if (ts == 0) ts = 1;

    percentage = ((widget.score / ts) * 100).toInt();
    isPassed = percentage >= 80;

    if (isPassed) {
      feedback =
          "Great job! You scored $percentage percent. The next level has been unlocked.";
      await ProgressTracker.saveScore(
        widget.category,
        widget.level,
        percentage,
      );
    } else if (percentage >= 80) {
      feedback =
          "Well done! You scored $percentage percent. You may continue to the next level.";
    } else {
      feedback =
          "You scored $percentage percent. Try again to unlock the next level.";
    }

    await TextToSpeech.speak(feedback);
    await Future.delayed(Duration(seconds: 2));

    if (percentage >= 80) {
      await TextToSpeech.speak(
        "Would you like to retry this level or go to the next one? Say next or retry.",
      );
    } else {
      await TextToSpeech.speak(
        "Would you like to listen to the lesson again and retry? Say yes or no.",
      );
    }
    _listenForNextAction();
  }

  Future<void> _listenForNextAction() async {
    setState(() {
      isListening = true;
    });

    String response = await VoiceInput.listen();

    setState(() {
      isListening = false;
    });

    if (percentage >= 80) {
      if (response.toLowerCase().contains("next")) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => LessonScreen(
                  category: widget.category,
                  level: widget.level + 1,
                ),
          ),
        );
      } else if (response.toLowerCase().contains("retry")) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    GameScreen(category: widget.category, level: widget.level, lessoncontent: widget.lessonContent,),
          ),
        );
      } else {
        await TextToSpeech.speak(
          "I didn't understand. Please say retry or next.",
        );
        _listenForNextAction();
      }
    } else {
      if (response.toLowerCase().contains("yes")) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => LessonScreen(
                  category: widget.category,
                  level: widget.level,
                  lessoncontent: widget.lessonContent,
                ),
          ),
        );
      } else if (response.toLowerCase().contains("no")) {
        await TextToSpeech.speak("Okay. You can try again later.");
      } else {
        await TextToSpeech.speak(
          "Would you like to listen to the lesson again and retry?",
        );
        _listenForNextAction();
      }
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
                image: AssetImage(
                  'lib/img/all back.jpg',
                ), // ✅ Ensure this is in your pubspec.yaml
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 📱 Foreground UI with levels
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(title: const Text("Quiz Result")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Category: ${widget.category}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    "Level: ${widget.level}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    "Score: $percentage%",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    feedback,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 40),
                  if (isListening) CircularProgressIndicator(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  LevelsScreen(category: widget.category),
                        ),
                      );
                    },
                    child: const Text("Back to Levels"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
