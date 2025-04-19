import 'package:string_similarity/string_similarity.dart';

class NLPUtils {
  static String cleanInput(String input) {
    input = input.toLowerCase().trim();

    // Remove filler words often used in speech
    final fillers = [
      "i think",
      "maybe",
      "it's",
      "the answer is",
      "my answer is",
      "i believe it's",
      "i believe",
      "i guess"
    ];

    for (var filler in fillers) {
      if (input.startsWith(filler)) {
        input = input.replaceFirst(filler, '').trim();
      }
    }

    // Remove punctuation and spaces
    input = input.replaceAll(RegExp(r'[^\w\s]'), '');
    return input;
  }

  static int? getBestMatchIndex(String userInput, List<String> options) {
    // Clean options (remove "A. ", "B. ", etc.)
    List<String> cleanedOptions = options.map((e) {
      return e.length > 3 ? e.substring(3).toLowerCase().trim() : e.toLowerCase();
    }).toList();

    var result = userInput.bestMatch(cleanedOptions);

    print("NLPUtils: Best match: ${result.bestMatch.target}, Rating: ${result.bestMatch.rating}");

    // Confidence threshold: adjust if needed
    final rating = result.bestMatch.rating;
    if (rating != null && rating >= 0.5) {
      return result.bestMatchIndex;
      }

    return null;
  }
}
