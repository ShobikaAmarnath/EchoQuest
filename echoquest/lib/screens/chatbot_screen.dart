import 'package:echoquest/services/ai_backend_service.dart';
import 'package:flutter/material.dart';
import 'package:echoquest/utils/voice_input.dart';
import 'package:echoquest/utils/text_to_speech.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<Map<String, String>> _messages = [];
  bool isManuallySelected = false;
  bool isListening = false;
  bool isSpeaking = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  void _stopAllActions() {
    TextToSpeech.stop();
    VoiceInput.stopListening();
    isSpeaking = false;
    isListening = false;
    isManuallySelected = true;
    _speech.stop();
  }

  @override
  void initState() {
    super.initState();
    _stopAllActions();
    _startConversation();
  }

  Future<void> _startConversation() async {
    await _addBotMessage(
      "Hi Kai, I am your AI learning companion and Personal assistance, Ask me anything like Photosynthesis, Trignometry or Tell me if you want to quit me or say like i want to play the lesson content again, i will help you to navigate the particular page. ",
    );
    await _listenAndRespond();
  }

  Future<void> _addBotMessage(String response) async {
    setState(() {
      _messages.add({'sender': 'bot', 'text': response});
      isSpeaking = true;
    });

    await TextToSpeech.speak(response);
    setState(() {
      isSpeaking = false;
    });
  }

  Future<void> _listenAndRespond() async {
    if (isSpeaking) return;

    setState(() => isListening = true);
    String spokenText = await VoiceInput.listen();
    setState(() => isListening = false);

    if (spokenText.trim().isEmpty) {
      await _addBotMessage("I didn't catch that. Please try again.");
    } else {
      setState(() {
        _messages.add({'sender': 'user', 'text': spokenText});
      });

      // 🔁 Fetch from your backend!
      String reply = await AIBackendService.fetchReply(spokenText);
      await _addBotMessage(reply);
    }

    await Future.delayed(Duration(milliseconds: 600));
    await _listenAndRespond();
  }

  Widget _buildMessage(Map<String, String> msg) {
    bool isUser = msg['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg['text'] ?? '', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Kai – AI Companion")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessage(_messages[i]),
            ),
          ),
          if (isListening)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "🎤 Listening...",
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
          if (isSpeaking)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "🗣️ Speaking...",
                style: TextStyle(color: Colors.amberAccent),
              ),
            ),
        ],
      ),
    );
  }
}
