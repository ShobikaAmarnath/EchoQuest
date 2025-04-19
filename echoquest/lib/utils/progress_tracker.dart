import 'package:shared_preferences/shared_preferences.dart';

class ProgressTracker {
  static Future<void> saveScore(String category, int level, int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$category-level$level', score);
  }

  static Future<int> getScore(String category, int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$category-level$level') ?? 0;
  }

  static Future<bool> isLevelUnlocked(String category, int level) async {
    if (level == 1) return true; // Level 1 is always unlocked

    int previousLevelScore = await getScore(category, level - 1);
    return previousLevelScore >= 90; // Unlock if previous level score is 90%+
  }

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Resets all saved progress
  }
}
