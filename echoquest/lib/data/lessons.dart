class LessonData {
  static final Map<String, Map<int, Map<String, String>>> lessons = {
    "Science": {
      1: {
        "Name": "Science - The Jungle of Juniper",
        "Topic": "Ecosystem & Adaptation",
      },
      2: {
        "Name": "Science - Magnetic Marvels",
        "Topic": "Magnets & Forces",
      }
    },
    "Maths": {
      1: {
        "Name": "Maths - The Number Kingdom",
        "Topic": "Basic Arithmetic",
      },
    }
  };

  // Function to get lesson details (Name + Topic)
  static Map<String, String> getLesson(String category, int level) {
    final lesson = lessons[category]?[level];
    if (lesson != null) {
      return lesson;
    } else {
      return {
        "Name": "Lesson not found",
        "Topic": "No topic available"
      };
    }
  }
}
