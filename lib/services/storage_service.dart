import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_word.dart';

class StorageService {
  static const String _keyWords = 'lingoread_saved_words';
  static const String _keyScores = 'lingoread_quiz_scores';
  static const String _keyFontSize = 'lingoread_reader_font_size';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Load all saved words from local storage
  static Future<List<SavedWord>> loadWords() async {
    final prefs = await _instance;
    final jsonStringList = prefs.getStringList(_keyWords) ?? [];
    return jsonStringList.map((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return SavedWord.fromJson(map);
    }).toList();
  }

  /// Save the entire list of words
  static Future<void> saveWords(List<SavedWord> words) async {
    final prefs = await _instance;
    final jsonStringList =
        words.map((w) => jsonEncode(w.toJson())).toList();
    await prefs.setStringList(_keyWords, jsonStringList);
  }

  /// Get saved score for an article (returns percentage 0-100 or null)
  static Future<int?> getQuizScore(String articleId) async {
    final prefs = await _instance;
    final scoresJson = prefs.getString(_keyScores);
    if (scoresJson == null) return null;
    final Map<String, dynamic> map = jsonDecode(scoresJson);
    return map[articleId] as int?;
  }

  /// Save quiz score for an article
  static Future<void> saveQuizScore(String articleId, int scorePercent) async {
    final prefs = await _instance;
    final scoresJson = prefs.getString(_keyScores);
    Map<String, dynamic> map = {};
    if (scoresJson != null) {
      map = jsonDecode(scoresJson);
    }
    // Keep highest score
    final previous = map[articleId] as int? ?? 0;
    if (scorePercent > previous) {
      map[articleId] = scorePercent;
    }
    await prefs.setString(_keyScores, jsonEncode(map));
  }

  /// Get reader font size
  static Future<double> getFontSize() async {
    final prefs = await _instance;
    return prefs.getDouble(_keyFontSize) ?? 17.0;
  }

  /// Save reader font size
  static Future<void> saveFontSize(double size) async {
    final prefs = await _instance;
    await prefs.setDouble(_keyFontSize, size);
  }
}
