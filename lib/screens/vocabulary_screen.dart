import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_word.dart';
import '../providers/vocabulary_provider.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  String _searchQuery = '';
  int _filterTab = 0; // 0: Tümü, 1: Öğrenilecekler, 2: Öğrenilenler

  @override
  Widget build(BuildContext context) {
    final vocab = context.watch<VocabularyProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    List<SavedWord> list = vocab.words;
    if (_filterTab == 1) {
      list = vocab.learningWords;
    } else if (_filterTab == 2) {
      list = vocab.learnedWords;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((w) {
        return w.word.toLowerCase().contains(q) ||
            w.meaning.toLowerCase().contains(q);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelime Haznem',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (vocab.words.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: FilledButton.tonalIcon(
                onPressed: () {
                  _startFlashcardStudy(context, vocab.learningWords.isNotEmpty
                      ? vocab.learningWords
                      : vocab.words);
                },
                icon: const Icon(Icons.style_rounded, size: 18),
                label: const Text('Pratik Yap'),
              ),
            ),
        ],
      ),
      body: vocab.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vocab.words.isEmpty
              ? _buildEmptyState(isDark)
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      children: [
                    // Statistics Summary Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E222D)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            title: 'Toplam',
                            count: vocab.words.length,
                            color: const Color(0xFF4F46E5),
                          ),
                          Container(
                              height: 36,
                              width: 1,
                              color: isDark ? Colors.grey[800] : Colors.grey[300]),
                          _buildStatItem(
                            title: 'Öğreniliyor',
                            count: vocab.learningWords.length,
                            color: Colors.amber[700]!,
                          ),
                          Container(
                              height: 36,
                              width: 1,
                              color: isDark ? Colors.grey[800] : Colors.grey[300]),
                          _buildStatItem(
                            title: 'Öğrenildi',
                            count: vocab.learnedWords.length,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Kelimelerde veya Türkçe anlamlarda ara...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1E222D)
                              : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildTabChip(0, 'Tümü (${vocab.words.length})'),
                          const SizedBox(width: 8),
                          _buildTabChip(1, 'Öğreniliyor (${vocab.learningWords.length})'),
                          const SizedBox(width: 8),
                          _buildTabChip(2, 'Öğrenildi (${vocab.learnedWords.length})'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Words List
                    Expanded(
                      child: list.isEmpty
                          ? Center(
                              child: Text(
                                'Aramaya uygun kelime bulunamadı.',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final item = list[index];
                                return _buildWordCard(
                                    context, item, vocab, isDark);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTabChip(int index, String label) {
    final isSelected = _filterTab == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterTab = index;
          });
        }
      },
    );
  }

  Widget _buildWordCard(BuildContext context, SavedWord item,
      VocabularyProvider vocab, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222D) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: IconButton(
          icon: Icon(
            item.isLearned
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: item.isLearned ? Colors.green : Colors.grey[400],
          ),
          tooltip: item.isLearned ? 'Öğrenildi' : 'Öğrenildi İşaretle',
          onPressed: () {
            vocab.toggleLearned(item.word);
          },
        ),
        title: Row(
          children: [
            Text(
              item.word,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                decoration: item.isLearned ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(width: 8),
            if (item.articleTitle != null)
              Expanded(
                child: Text(
                  item.articleTitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.meaning,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.indigo[200] : const Color(0xFF4F46E5),
              ),
            ),
            if (item.contextSentence.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '"${item.contextSentence}"',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded,
              size: 20, color: Colors.grey[400]),
          tooltip: 'Hazneden Sil',
          onPressed: () {
            vocab.removeWord(item.word);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 64,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz kelime eklemedin!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Gazete haberlerini ve hikayeleri okurken bilmediğin kelimelere dokunarak buraya ekleyebilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startFlashcardStudy(BuildContext context, List<SavedWord> words) {
    if (words.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardStudyScreen(words: words),
      ),
    );
  }
}

class FlashcardStudyScreen extends StatefulWidget {
  final List<SavedWord> words;

  const FlashcardStudyScreen({super.key, required this.words});

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  int _currentIndex = 0;
  bool _showMeaning = false;

  @override
  Widget build(BuildContext context) {
    final word = widget.words[_currentIndex];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelime Pratiği (${_currentIndex + 1}/${widget.words.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.words.length,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 24),

            // Flashcard
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showMeaning = !_showMeaning;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E222D)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _showMeaning
                          ? const Color(0xFF4F46E5)
                          : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showMeaning ? 'TÜRKÇE ANLAMI' : 'İNGİLİZCE KELİME',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _showMeaning ? word.meaning : word.word,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _showMeaning ? 24 : 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (!_showMeaning && word.contextSentence.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.2)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '"${word.contextSentence}"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app_rounded,
                              size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 6),
                          Text(
                            _showMeaning
                                ? 'Kelimeyi görmek için dokun'
                                : 'Anlamı görmek için dokun',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Controls
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _nextCard();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Tekrar Et'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<VocabularyProvider>()
                          .toggleLearned(word.word);
                      _nextCard();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Öğrendim ✓',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  void _nextCard() {
    if (_currentIndex + 1 < widget.words.length) {
      setState(() {
        _currentIndex++;
        _showMeaning = false;
      });
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tebrikler! Kelime pratiğini tamamladın.'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
