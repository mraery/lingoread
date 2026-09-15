import 'package:flutter/foundation.dart';
import '../models/saved_word.dart';
import '../services/dictionary_service.dart';
import '../services/storage_service.dart';

class VocabularyProvider with ChangeNotifier {
  List<SavedWord> _words = [];
  bool _isLoading = true;

  List<SavedWord> get words => List.unmodifiable(_words);
  bool get isLoading => _isLoading;

  List<SavedWord> get learningWords =>
      _words.where((w) => !w.isLearned).toList();

  List<SavedWord> get learnedWords =>
      _words.where((w) => w.isLearned).toList();

  VocabularyProvider() {
    loadSavedWords();
  }

  Future<void> loadSavedWords() async {
    _isLoading = true;
    notifyListeners();
    try {
      _words = await StorageService.loadWords();
    } catch (e) {
      debugPrint('Error loading saved words: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isWordSaved(String rawWord) {
    final clean = DictionaryService.cleanWord(rawWord);
    return _words.any((w) => w.word.toLowerCase() == clean);
  }

  SavedWord? getSavedWord(String rawWord) {
    final clean = DictionaryService.cleanWord(rawWord);
    try {
      return _words.firstWhere((w) => w.word.toLowerCase() == clean);
    } catch (_) {
      return null;
    }
  }

  Future<void> addWord({
    required String rawWord,
    required String meaning,
    required String contextSentence,
    String? articleTitle,
  }) async {
    final clean = DictionaryService.cleanWord(rawWord);
    if (clean.isEmpty) return;

    // Check if already exists
    final existingIndex =
        _words.indexWhere((w) => w.word.toLowerCase() == clean);
    if (existingIndex >= 0) {
      // Update existing word if needed
      _words[existingIndex] = SavedWord(
        word: clean,
        meaning: meaning,
        contextSentence: contextSentence,
        dateAdded: DateTime.now(),
        isLearned: false,
        articleTitle: articleTitle ?? _words[existingIndex].articleTitle,
      );
    } else {
      _words.insert(
        0,
        SavedWord(
          word: clean,
          meaning: meaning,
          contextSentence: contextSentence,
          dateAdded: DateTime.now(),
          isLearned: false,
          articleTitle: articleTitle,
        ),
      );
    }

    notifyListeners();
    await StorageService.saveWords(_words);
  }

  Future<void> removeWord(String rawWord) async {
    final clean = DictionaryService.cleanWord(rawWord);
    _words.removeWhere((w) => w.word.toLowerCase() == clean);
    notifyListeners();
    await StorageService.saveWords(_words);
  }

  Future<void> toggleLearned(String rawWord) async {
    final clean = DictionaryService.cleanWord(rawWord);
    final index = _words.indexWhere((w) => w.word.toLowerCase() == clean);
    if (index >= 0) {
      _words[index].isLearned = !_words[index].isLearned;
      notifyListeners();
      await StorageService.saveWords(_words);
    }
  }
}
