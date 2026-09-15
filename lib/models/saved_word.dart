class SavedWord {
  final String word;
  final String meaning;
  final String contextSentence;
  final DateTime dateAdded;
  bool isLearned;
  final String? articleTitle;

  SavedWord({
    required this.word,
    required this.meaning,
    required this.contextSentence,
    required this.dateAdded,
    this.isLearned = false,
    this.articleTitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      'contextSentence': contextSentence,
      'dateAdded': dateAdded.toIso8601String(),
      'isLearned': isLearned,
      'articleTitle': articleTitle,
    };
  }

  factory SavedWord.fromJson(Map<String, dynamic> json) {
    return SavedWord(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      contextSentence: json['contextSentence'] as String? ?? '',
      dateAdded: DateTime.tryParse(json['dateAdded'] as String? ?? '') ??
          DateTime.now(),
      isLearned: json['isLearned'] as bool? ?? false,
      articleTitle: json['articleTitle'] as String?,
    );
  }
}
