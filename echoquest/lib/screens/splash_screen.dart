import 'package:flutter/material.dart';
import 'package:echoquest/utils/text_to_speech.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Play welcome speech
    TextToSpeech.speak("Welcome to EchoQuest! Get ready to learn with sound.");
    print("Welcome speech is narrating");

    // Navigate to home screen after speech completes
    Future.delayed(Duration(seconds: 7), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo Image
            Image.asset(
              'lib/img/logo.jpg', // Make sure the image file is named correctly
              width: 150, // Adjust size as needed
              height: 150,
              fit: BoxFit.contain, // Ensures proper scaling
            ),
            SizedBox(height: 20), // Space between logo and text

            // App Title
            // Text(
            //   "EchoQuest",
            //   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            // ),
          ],
        ),
      ),
    );
  }
}
