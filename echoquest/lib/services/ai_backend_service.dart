import 'dart:convert';
import 'package:echoquest/data/questions.dart';
import 'package:http/http.dart' as http;

class AIBackendService {
  static const String baseUrl = 'http://192.168.29.213:8000';

  static Future<String> fetchLesson(
    String category,
    int level,
    String topic,
  ) async {
    print(
      "fetching lesson for category: $category, level: $level, topic: $topic",
    );

    final uri = Uri.parse(
      '$baseUrl/generate-lesson?category=${Uri.encodeComponent(category)}&level=${level.toString()}&topic=${Uri.encodeComponent(topic)}',
    );

    final response = await http.get(uri);

    print("response: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['lesson'];
    } else {
      throw Exception('Failed to load lesson');
    }
  }

  static Future<List<Question>> fetchQuestions(
    String category,
    int level,
    String lessoncontent,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/generate-questions?category=${Uri.encodeComponent(category)}&level=${level.toString()}&topic=${Uri.encodeComponent(lessoncontent)}',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> rawQuestions = jsonDecode(response.body)['questions'];
      final questionList = _parseQuestions(rawQuestions);
      print(questionList);
      return questionList;
    } else {
      throw Exception('Failed to load questions');
    }
  }

  static List<Question> _parseQuestions(List<dynamic> raw) {
  return raw.map((item) => Question.fromJson(item)).toList();
}

} 