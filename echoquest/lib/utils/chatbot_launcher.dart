import 'package:flutter/material.dart';
import 'package:echoquest/screens/chatbot_screen.dart';
import 'package:echoquest/main.dart';

void launchChatbot() {
  navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (context) => ChatBotScreen()),
  );
}
