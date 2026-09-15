import 'quiz_question.dart';

enum ArticleType {
  news,
  story,
}

class Article {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final ArticleType type;
  final String level; // A2, B1, B2, C1
  final int readTimeMinutes;
  final String authorOrSource;
  final DateTime date;
  final List<String> paragraphs;
  final List<QuizQuestion> quizQuestions;
  final String iconEmoji;
  final String imageUrl;

  const Article({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.type,
    required this.level,
    required this.readTimeMinutes,
    required this.authorOrSource,
    required this.date,
    required this.paragraphs,
    required this.quizQuestions,
    required this.iconEmoji,
    required this.imageUrl,
  });

  String get fullText => paragraphs.join('\n\n');
}
