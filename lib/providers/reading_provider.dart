import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/content_service.dart';
import '../services/storage_service.dart';

enum ReaderThemeMode {
  light,
  sepia,
  dark,
}

class ReadingProvider with ChangeNotifier {
  double _fontSize = 17.5;
  ReaderThemeMode _readerTheme = ReaderThemeMode.light;
  final Map<String, int> _quizScores = {};
  final List<Article> _articles = ContentService.getArticles();
  String _selectedCategory = 'Tümü';

  double get fontSize => _fontSize;
  ReaderThemeMode get readerTheme => _readerTheme;
  Map<String, int> get quizScores => _quizScores;
  List<Article> get articles => _articles;
  String get selectedCategory => _selectedCategory;

  ReadingProvider() {
    _init();
  }

  Future<void> _init() async {
    _fontSize = await StorageService.getFontSize();

    // Load saved scores for each article
    for (var a in _articles) {
      final score = await StorageService.getQuizScore(a.id);
      if (score != null) {
        _quizScores[a.id] = score;
      }
    }
    notifyListeners();
  }

  void setReaderTheme(ReaderThemeMode mode) {
    _readerTheme = mode;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Article> get filteredArticles {
    if (_selectedCategory == 'Tümü') {
      return _articles;
    } else if (_selectedCategory == 'Gazete Haberleri') {
      return _articles.where((a) => a.type == ArticleType.news).toList();
    } else if (_selectedCategory == 'Hikayeler') {
      return _articles.where((a) => a.type == ArticleType.story).toList();
    } else {
      return _articles.where((a) => a.level == _selectedCategory).toList();
    }
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(14.0, 28.0);
    notifyListeners();
    await StorageService.saveFontSize(_fontSize);
  }

  Future<void> recordQuizResult(String articleId, int percent) async {
    final current = _quizScores[articleId] ?? 0;
    if (percent > current) {
      _quizScores[articleId] = percent;
    }
    notifyListeners();
    await StorageService.saveQuizScore(articleId, percent);
  }

  int? getArticleScore(String articleId) {
    return _quizScores[articleId];
  }
}
