import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/reading_provider.dart';

class QuizScreen extends StatefulWidget {
  final Article article;

  const QuizScreen({super.key, required this.article});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  int _correctCount = 0;
  bool _isQuizFinished = false;

  @override
  Widget build(BuildContext context) {
    final questions = widget.article.quizQuestions;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isQuizFinished) {
      return _buildResultScreen(context, questions.length, isDark);
    }

    final currentQuestion = questions[_currentIndex];
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Anlama Testi (${_currentIndex + 1}/${questions.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Article Badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.article.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Question Box
            Text(
              currentQuestion.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 24),

            // Option Cards
            ...List.generate(currentQuestion.options.length, (index) {
              final optionText = currentQuestion.options[index];
              return _buildOptionCard(
                index: index,
                text: optionText,
                correctIndex: currentQuestion.correctOptionIndex,
                isDark: isDark,
              );
            }),

            const SizedBox(height: 20),

            // Explanation Card (shows after answer is selected)
            if (_answered) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedOptionIndex ==
                          currentQuestion.correctOptionIndex
                      ? (isDark
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.green.withValues(alpha: 0.08))
                      : (isDark
                          ? Colors.amber.withValues(alpha: 0.15)
                          : Colors.amber.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedOptionIndex ==
                            currentQuestion.correctOptionIndex
                        ? Colors.green.withValues(alpha: 0.4)
                        : Colors.amber.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedOptionIndex ==
                                  currentQuestion.correctOptionIndex
                              ? Icons.check_circle_rounded
                              : Icons.info_outline_rounded,
                          size: 18,
                          color: _selectedOptionIndex ==
                                  currentQuestion.correctOptionIndex
                              ? Colors.green
                              : Colors.amber[800],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedOptionIndex ==
                                  currentQuestion.correctOptionIndex
                              ? 'Doğru Cevap!'
                              : 'Açıklama:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _selectedOptionIndex ==
                                    currentQuestion.correctOptionIndex
                                ? Colors.green[700]
                                : Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentQuestion.explanation,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: isDark ? Colors.grey[200] : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Next / Finish button
            if (_answered)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex + 1 < questions.length) {
                      setState(() {
                        _currentIndex++;
                        _selectedOptionIndex = null;
                        _answered = false;
                      });
                    } else {
                      _finishQuiz(questions.length);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _currentIndex + 1 < questions.length
                        ? 'Sonraki Soru'
                        : 'Sonuçları Gör',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildOptionCard({
    required int index,
    required String text,
    required int correctIndex,
    required bool isDark,
  }) {
    Color cardBorder =
        isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0);
    Color cardBg = isDark ? const Color(0xFF1E222D) : Colors.white;
    Color optionLetterBg =
        isDark ? Colors.grey[800]! : const Color(0xFFF1F5F9);
    Color optionLetterText =
        isDark ? Colors.grey[300]! : const Color(0xFF475569);

    if (_answered) {
      if (index == correctIndex) {
        cardBorder = Colors.green;
        cardBg = isDark
            ? Colors.green.withValues(alpha: 0.2)
            : const Color(0xFFECFDF5);
        optionLetterBg = Colors.green;
        optionLetterText = Colors.white;
      } else if (index == _selectedOptionIndex) {
        cardBorder = Colors.redAccent;
        cardBg = isDark
            ? Colors.red.withValues(alpha: 0.2)
            : const Color(0xFFFEF2F2);
        optionLetterBg = Colors.redAccent;
        optionLetterText = Colors.white;
      }
    } else if (_selectedOptionIndex == index) {
      cardBorder = const Color(0xFF4F46E5);
      cardBg = isDark ? const Color(0xFF282F3F) : const Color(0xFFEEF2FF);
    }

    final letters = ['A', 'B', 'C', 'D'];
    final letter = index < letters.length ? letters[index] : '${index + 1}';

    return GestureDetector(
      onTap: _answered
          ? null
          : () {
              setState(() {
                _selectedOptionIndex = index;
                _answered = true;
                if (index == correctIndex) {
                  _correctCount++;
                }
              });
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: optionLetterBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: optionLetterText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      _selectedOptionIndex == index || (_answered && index == correctIndex)
                          ? FontWeight.w600
                          : FontWeight.normal,
                  color: isDark ? Colors.grey[200] : const Color(0xFF1E293B),
                ),
              ),
            ),
            if (_answered) ...[
              if (index == correctIndex)
                const Icon(Icons.check_circle_rounded, color: Colors.green)
              else if (index == _selectedOptionIndex)
                const Icon(Icons.cancel_rounded, color: Colors.redAccent),
            ],
          ],
        ),
      ),
    );
  }

  void _finishQuiz(int total) {
    final percent = ((_correctCount / total) * 100).round();
    context.read<ReadingProvider>().recordQuizResult(widget.article.id, percent);
    setState(() {
      _isQuizFinished = true;
    });
  }

  Widget _buildResultScreen(BuildContext context, int total, bool isDark) {
    final percent = ((_correctCount / total) * 100).round();
    final isSuccess = percent >= 75;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonucu'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isSuccess ? Icons.emoji_events_rounded : Icons.menu_book_rounded,
                    size: 48,
                    color: isSuccess ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isSuccess
                    ? 'Harika Kavrama!'
                    : 'Metni Tekrar Gözden Geçir!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$total sorudan $_correctCount tanesini doğru yanıtladın.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E222D)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSuccess
                        ? Colors.green.withValues(alpha: 0.4)
                        : Colors.orange.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'Başarı: %$percent',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isSuccess ? Colors.green : Colors.orange[800],
                  ),
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                      _selectedOptionIndex = null;
                      _answered = false;
                      _correctCount = 0;
                      _isQuizFinished = false;
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text(
                    'Testi Tekrar Çöz',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Metne Geri Dön',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
