// import 'package:echoquest/utils/skip_button.dart';
import 'package:flutter/material.dart';
import 'package:echoquest/utils/text_to_speech.dart';
import 'package:echoquest/utils/voice_input.dart';
// import 'package:echoquest/utils/audio_feedback.dart'; // New utility for mic sounds
import 'levels_screen.dart';

final String intro = '''In the ancient world of Sonaria, wisdom was stored in Echo Crystals, magical stones that held the secrets of Science, Technology, Engineering, Arts, and Mathematics (STEAM). These crystals kept the world in balance, helping civilizations grow and learn.

One day, a catastrophic event known as the Silent Eclipse shattered the Echo Crystals, scattering their fragments across the lands. Without knowledge, Sonaria fell into darkness, and people could no longer solve problems or understand the world around them.

You play as Kai, a young explorer chosen by the mysterious guardian spirit, Echo, to embark on a journey to restore lost knowledge. Unlike past explorers, Kai possesses a unique gift—the ability to hear knowledge, while the rest of the world can only see. This makes Kai the only one capable of interpreting the whispers of knowledge and restoring balance to Sonaria. In a world where sound is lost to all but you, hearing becomes your superpower.

Your journey will not be a straight path; you must choose your own way to uncover the secrets of Sonaria.''';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = ["Science", "Math", "Technology"];
  bool isListening = false;
  bool isManuallySelected = false;
  
  // get _flutterTts => null; // Detect manual selection

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSkipOrContinue();
    });
  }

  Future<void> _checkSkipOrContinue() async {
    await Future.delayed(Duration(seconds: 1));
    await TextToSpeech.speak("Say Continue to listen to the intro narration or else Say Skip to skip the intro narration");
    String sorc = await VoiceInput.listen();

    if (sorc.toLowerCase().contains("continue")) {
      await TextToSpeech.speak(intro);
      await Future.delayed(Duration(seconds: 2));
      _promptUser();
    }
    else if (sorc.toLowerCase().contains("skip")) {
      _promptUser();
    }
    else {
      await TextToSpeech.speak("I didn't hear a valid response. Please try again.");
      await Future.delayed(Duration(seconds: 1));
      _checkSkipOrContinue();
    }

  }

  Future<void> _promptUser() async {
    await Future.delayed(Duration(seconds: 1));
    // await TextToSpeech.speak(intro);
    // await Future.delayed(Duration(seconds: 2));
    await TextToSpeech.speak("Choose a category: Maths, Science, Technology");
    await Future.delayed(Duration(seconds: 2));

    // If user has not manually selected a category, start listening
    if (!isManuallySelected) {
      _listenForCategory();
    }
  }

  void _listenForCategory() async {
    setState(() {
      isListening = true;
    });

    // await AudioFeedback.playListeningSound(); // Play mic ON sound
    String spokenText = await VoiceInput.listen();

    setState(() {
      isListening = false;
    });

    // await AudioFeedback.playStopListeningSound(); // Play mic OFF sound

    // Stop listening & speaking when navigating manually
    if (isManuallySelected) return;

    if (spokenText.isNotEmpty) {
      String matchedCategory = categories.firstWhere(
        (category) =>
            spokenText.trim().isNotEmpty &&
            spokenText.trim().toLowerCase()[0] == category.toLowerCase()[0],
        orElse: () => '',
      );

      if (matchedCategory.isNotEmpty) {
        _navigateToCategory(matchedCategory);
      } else {
        await TextToSpeech.speak(
          "I didn't recognize that category. Please try again.",
        );
        await Future.delayed(Duration(seconds: 1));
        _promptUser();
      }
    } else {
      await TextToSpeech.speak("I didn't hear anything. Please try again.");
      await Future.delayed(Duration(seconds: 1));
      _promptUser();
    }
  }

  void _navigateToCategory(String category) {
    _stopAllActions(); // Stop current speech and listening

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LevelsScreen(category: category)),
    ).then((_) {
      // Resume listening when coming back (if needed)
      isManuallySelected = false; // Reset manual selection
      _promptUser(); // Start speech again when returning
    });
  }

  void _stopAllActions() {
    TextToSpeech.stop(); // Stop text-to-speech
    VoiceInput.stopListening(); // Stop voice input
    setState(() {
      isListening = false;
      isManuallySelected = true; // Mark manual selection
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Select Category")),
    body: Stack(
      children: [
        // 🔮 Background Image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/img/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 🧭 Positioned Column aligned to just below "CHOOSE YOUR THEME"
        Positioned(
          top: MediaQuery.of(context).size.height * 0.5, // Adjust this value to match "CHOOSE YOUR THEME"
          left: 0,
          right: 0,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (String category in categories)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _stopAllActions();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LevelsScreen(category: category),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        // backgroundColor: Colors.black.withOpacity(0.7),
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontFamily: "Old English Text MT",
                        ),
                      ),
                      child: Text(category),
                    ),
                  ),
                ),
              if (isListening)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
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