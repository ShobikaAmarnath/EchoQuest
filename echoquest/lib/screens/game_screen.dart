import 'package:echoquest/services/ai_backend_service.dart';
import 'package:echoquest/utils/sound_helper.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../data/questions.dart';
import '../utils/text_to_speech.dart';
import '../utils/voice_input.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final String category;
  final int level;
  final String lessoncontent;

  const GameScreen({
    super.key,
    required this.category,
    required this.level,
    required this.lessoncontent,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Question> qs = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isManuallySelected = false;
  bool isLoading = true;  
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    print('GameScreen: initState() called');
    _loadQuestions();
  }

  void _stopAllActions() {
  TextToSpeech.stop();
    VoiceInput.stopListening();
    _isSpeaking = false;
    _isListening = false;
    _isManuallySelected = true;
    _speech.stop();
}

  void _loadQuestions() async {
    print('GameScreen: _loadQuestions() called');
    print('******************generating questions******************');

    try {
      final fetched = await AIBackendService.fetchQuestions(
        widget.category,
        widget.level,
        widget.lessoncontent,
      );
      print("*******************questions generated******************");
      print(fetched);
      if (fetched.isEmpty) {
        _loadQuestions();
      }
      setState(() {
        qs = fetched;
        isLoading = false;
      });
      if (qs.isNotEmpty) {
        Future.delayed(Duration(seconds: 1), _askQuestion);
      }
    } catch (e) {
      print('Error fetching questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      
      if (event.logicalKey.keyLabel == ' ') {
        print("Spacebar pressed");
        // You can call a function like _askQuestion() or trigger narration
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
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 📱 Foreground UI with levels
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(automaticallyImplyLeading: false),
            body:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_currentIndex < qs.length)
                            Text(
                              qs[_currentIndex].question,
                              style: TextStyle(fontSize: 24.0),
                              textAlign: TextAlign.center,
                            ),
                          SizedBox(height: 20.0),
                          if (_currentIndex < qs.length)
                            ...qs[_currentIndex].options.asMap().entries.map((
                              entry,
                            ) {
                              int i = entry.key;
                              String option = entry.value;
                              return ElevatedButton(
                                onPressed: () {
                                  _stopAllActions();
                                  _checkAnswer(option);
                                },
                                child: Text(
                                  "${String.fromCharCode(65 + i)}. $option",
                                ),
                              );
                            }),
                          SizedBox(height: 20.0),
                          if (_isListening)
                            Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 10.0),
                                  Text(
                                    'Listening...',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _askQuestion() async {
    print('GameScreen: _askQuestion() called');
    // _stopAllActions();

    if (_isManuallySelected) return;
    if (_currentIndex < qs.length) {
      await TextToSpeech.speak(qs[_currentIndex].question);
      await Future.delayed(Duration(seconds: 2));

      for (int i = 0; i < qs[_currentIndex].options.length; i++) {
        await TextToSpeech.speak(
          "Option ${String.fromCharCode(65 + i)}: ${qs[_currentIndex].options[i]}",
        );
        await Future.delayed(Duration(seconds: 1));
      }

      while (true) {
        setState(() {
          _isListening = true;
        });

        print('GameScreen: Waiting for user input');
        
        SoundHelper.playMicSound();
        if(_isManuallySelected) return;
        String answer = await VoiceInput.listen();

        setState(() {
          _isListening = false;
        });

        if (answer.isEmpty) {
          print("GameScreen: No response detected, asking to try again.");
          await TextToSpeech.speak("I didn't catch that. Please try again.");
          continue;
        }

        print('GameScreen: User input received: $answer');
        _checkAnswer(answer);
        break;
      }
    } else {
      _goToResultScreen();
    }
  }

  void _checkAnswer(String answer) async {
    print('GameScreen: _checkAnswer() called with answer: $answer');

    List<String> options = qs[_currentIndex].options;
    int correctIndex = qs[_currentIndex].correctAnswer;

    print('GameScreen: Options: $options');
    print('GameScreen: Correct Option Index: $correctIndex');
    print('GameScreen: Correct Option: ${options[correctIndex]}');

    int? predictedIndex;
    for (int i = 0; i < options.length; i++) {
      final option = options[i].toLowerCase().trim();
      if (answer.toLowerCase().contains(option) ||
          answer.toLowerCase().contains(
            String.fromCharCode(65 + i).toLowerCase(),
          )) {
        predictedIndex = i;
        break;
      }
    }

    print('GameScreen: Predicted Index: $predictedIndex');

    if (predictedIndex != null && predictedIndex == correctIndex) {
      _score++;
      print("✅ Correct! Score is now $_score");
    } else {
      print("❌ Incorrect.");
    }

    _currentIndex++;

    if (_currentIndex < qs.length) {
      setState(() {});
      await _askQuestion();
    } else {
      print('Game Over! Final Score: $_score out of ${qs.length}');
      _goToResultScreen();
    }
  }

  void _goToResultScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => ResultScreen(
              score: _score,
              totalQuestions: qs.length,
              questions: qs,
              category: widget.category,
              level: widget.level,
              lessonContent: widget.lessoncontent,
            ),
      ),
    );
  }

  
}


