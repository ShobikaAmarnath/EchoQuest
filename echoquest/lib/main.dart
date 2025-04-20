import 'package:echoquest/spacebar.dart';
import 'package:flutter/material.dart';
import 'package:echoquest/screens/splash_screen.dart';
import 'package:echoquest/utils/sound_helper.dart'; // ✅ Required import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundHelper.preloadBeepSound(); // ✅ preload for web
  runApp(const EchoQuestApp());
}

class EchoQuestApp extends StatelessWidget {
  const EchoQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalChatbotListener(
      child: MaterialApp(
        title: 'EchoQuest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: SplashScreen(),
      ),
    );
  }
}
