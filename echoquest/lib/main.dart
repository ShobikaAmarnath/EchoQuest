import 'package:echoquest/spacebar.dart';
import 'package:echoquest/utils/bluetooth_listener.dart';
import 'package:flutter/material.dart';
import 'package:echoquest/screens/splash_screen.dart';
import 'package:echoquest/utils/sound_helper.dart'; // ✅ Required import
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  

  WidgetsFlutterBinding.ensureInitialized();
  await SoundHelper.preloadBeepSound(); // ✅ preload for web
  runApp(const EchoQuestApp());
}

class EchoQuestApp extends StatelessWidget {
  const EchoQuestApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'EchoQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      navigatorKey: navigatorKey,
      home: Builder(
        builder: (context) {
          BluetoothListener().start(context); // Start Bluetooth listener

          return SpacebarListener(
            child: SplashScreen(),
          ); // Wrap with SpacebarListener
        },
      ),
    );
  }
}
