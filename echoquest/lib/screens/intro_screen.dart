import 'package:echoquest/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:echoquest/utils/text_to_speech.dart';
import 'package:echoquest/utils/voice_input.dart';

final String intro =
    '''In the ancient world of Sonaria, wisdom was stored in Echo Crystals, magical stones that held the secrets of Science, Technology, Engineering, Arts, and Mathematics (STEAM). These crystals kept the world in balance, helping civilizations grow and learn.

One day, a catastrophic event known as the Silent Eclipse shattered the Echo Crystals, scattering their fragments across the lands. Without knowledge, Sonaria fell into darkness, and people could no longer solve problems or understand the world around them.

You play as Kai, a young explorer chosen by the mysterious guardian spirit, Echo, to embark on a journey to restore lost knowledge. Unlike past explorers, Kai possesses a unique gift—the ability to hear knowledge, while the rest of the world can only see. This makes Kai the only one capable of interpreting the whispers of knowledge and restoring balance to Sonaria. In a world where sound is lost to all but you, hearing becomes your superpower.

Your journey will not be a straight path; you must choose your own way to uncover the secrets of Sonaria.''';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool isNarrating = false;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSkipOrContinue();
    });
  }

  Future<void> _checkSkipOrContinue() async {
    _stopAllActions();
    setState(() {
      isListening = true;
    });

    await Future.delayed(Duration(seconds: 1));
    await TextToSpeech.speak(
      "Say Continue to listen to the intro narration or say Skip to skip the intro narration.",
    );

    String sorc = await VoiceInput.listen();

    if (sorc.toLowerCase().contains("continue")) {
      _handleContinue();
    } else if (sorc.toLowerCase().contains("skip")) {
      _handleSkip();
    } else {
      setState(() {
        isListening = false;
      });

      await TextToSpeech.speak(
        "I didn't hear a valid response. Please try again.",
      );
      await Future.delayed(Duration(seconds: 1));
      _checkSkipOrContinue();
    }
  }

  void _handleContinue() async {
    setState(() {
      isNarrating = true;
      isListening = false;
    });
    await TextToSpeech.speak(intro);
    setState(() => isNarrating = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _handleSkip() {
    setState(() {
      isListening = false;
      isNarrating = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _stopAllActions() {
    TextToSpeech.stop();
    VoiceInput.stopListening();
    setState(() {
      isListening = false;
      isNarrating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/img/intro.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 📖 Intro Text + Buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 120,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          intro,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Georgia",
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  if (isNarrating || isListening)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _stopAllActions();
                          _handleSkip();
                        },
                        child: Text("Skip"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _stopAllActions();
                          _handleContinue();
                        },
                        child: Text("Continue"),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
