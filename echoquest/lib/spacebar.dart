import 'package:echoquest/screens/chatbot_screen.dart';
import 'package:flutter/material.dart';

class GlobalChatbotListener extends StatelessWidget {
  final Widget child;

  const GlobalChatbotListener({super.key, required this.child});

  void _handleKeyPress(RawKeyEvent event, BuildContext context) {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.logicalKey.keyLabel == ' ') {
        print("🔊 Global spacebar pressed");
        // Navigate to your chatbot screen or show overlay
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ChatBotScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(), // Always focused
      autofocus: true,
      onKey: (event) => _handleKeyPress(event, context),
      child: child,
    );
  }
}
