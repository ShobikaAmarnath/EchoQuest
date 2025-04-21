import 'package:flutter/material.dart';
import 'utils/chatbot_launcher.dart';

class SpacebarListener extends StatelessWidget {
  final Widget child;

  const SpacebarListener({super.key, required this.child});

  void _handleKeyPress(RawKeyEvent event, BuildContext context) {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.logicalKey.keyLabel == ' ') {
        launchChatbot();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKey: (event) => _handleKeyPress(event, context),
      child: child,
    );
  }
}
