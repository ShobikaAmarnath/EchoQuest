import 'package:flutter/material.dart';
import 'package:echoquest/utils/text_to_speech.dart';
import 'package:echoquest/utils/voice_input.dart';
import 'package:echoquest/data/lessons.dart';
import 'package:echoquest/screens/game_screen.dart';
import 'package:echoquest/services/ai_backend_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LessonScreen extends StatefulWidget {
  final String category;
  final int level;
  final String? lessoncontent;

  LessonScreen({required this.category, required this.level, this.lessoncontent,});

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late String lessonText;
  late String intro;
  bool isLoading = true;
  bool isListening = false;
  bool isSpeaking = false;
  bool isMounted = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    intro =
        "Welcome to Level ${widget.level} in ${widget.category}. Here’s your lesson...";
    // _loadLesson();
    if(widget.lessoncontent != null && widget.lessoncontent!.trim().isNotEmpty) {
      print("***********lesson content is not null**************");
      lessonText = widget.lessoncontent!;
    }
    else {
      _loadLesson();
    }
    _checkSkipOrContinue();
  }

  Future<void> _checkSkipOrContinue() async {
    await Future.delayed(Duration(seconds: 1));
    await TextToSpeech.speak(
      "Say Continue to listen to the Lesson content or else Say Skip to skip the lesson content",
    );
    String sorc = await VoiceInput.listen();

    if (sorc.toLowerCase().contains("continue")) {
      await TextToSpeech.speak(intro);
      await Future.delayed(Duration(seconds: 2));
      _speakLesson();
    } else if (sorc.toLowerCase().contains("skip")) {
      _startQuiz();
    } else {
      await TextToSpeech.speak(
        "I didn't hear a valid response. Please try again.",
      );
      await Future.delayed(Duration(seconds: 1));
      _checkSkipOrContinue();
    }
  }

  @override
  void dispose() {
    isMounted = false;
    _stopAllActions();
    super.dispose();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.logicalKey.keyLabel == ' ') {
        print("Spacebar pressed");
        // You can call a function like _askQuestion() or trigger narration
      }
    }
  }

  void _stopAllActions() {
    TextToSpeech.stop();
    VoiceInput.stopListening();
  }

  void _loadLesson() async {
    try {
      final lessonDetails = LessonData.getLesson(widget.category, widget.level);
      final topic = lessonDetails['Topic'] ?? 'General Topic';
            
      print("***********get lesson called successfully**************");

      final lesson = await AIBackendService.fetchLesson(
        widget.category,
        widget.level,
        topic,
      );
      print("***********fetch lesson called successfully**************");
      setState(() {
        lessonText = lesson.replaceAll(r'\n', '\n');
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        lessonText = 'Error loading lesson.';
        isLoading = false;
      });
    }
  }

  void _speakLesson() async {
    _stopAllActions();
    isSpeaking = true;

    // await TextToSpeech.speak("Welcome to Level ${widget.level} in ${widget.category}. Here’s your lesson...");
    // await Future.delayed(Duration(seconds: 1));

    if (!isMounted) return;
    await TextToSpeech.speakParagraph(lessonText);
    await Future.delayed(Duration(seconds: 2));
    _startQuiz();
  }

  void _startQuiz() async {
    _stopAllActions();
    isSpeaking = true;

    if (!isMounted) return;
    await TextToSpeech.speak("Say Start to start the quiz.");

    if (!isMounted) return;
    _listenForQuizCommand();
  }

  void _listenForQuizCommand() async {
    if (!isMounted) return;
    setState(() {
      isListening = true;
    });

    String spokenText = await VoiceInput.listen();

    if (!isMounted) return;
    setState(() {
      isListening = false;
    });

    if (spokenText.toLowerCase().contains("start")) {
      _stopAllActions();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  GameScreen(category: widget.category, level: widget.level, lessoncontent: lessonText,),
        ),
      );
    } else {
      if (!isMounted) return;
      await TextToSpeech.speak(
        "I didn't recognize that. Please say Start Quiz to begin.",
      );
      await Future.delayed(Duration(seconds: 2));
      _listenForQuizCommand();
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
            appBar: AppBar(title: Text("Lesson - Level ${widget.level}")),
            body:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: MarkdownBody(data: lessonText)
                            ),
                          ),
                          SizedBox(height: 20),
                          if (isListening) CircularProgressIndicator(),
                          ElevatedButton(
                            onPressed: () {
                              _stopAllActions();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => GameScreen(
                                        category: widget.category,
                                        level: widget.level,
                                        lessoncontent: lessonText,
                                      ),
                                ),
                              );
                            },
                            child: Text("Start Quiz"),
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
