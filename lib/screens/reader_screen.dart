import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/reading_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/interactive_paragraph.dart';
import 'quiz_screen.dart';

class ReaderScreen extends StatefulWidget {
  final Article article;

  const ReaderScreen({
    super.key,
    required this.article,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  double _readingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (max > 0) {
      setState(() {
        _readingProgress = (current / max).clamp(0.0, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final readingProvider = context.watch<ReadingProvider>();
    final themeMode = readingProvider.readerTheme;
    final isDarkSystem = Theme.of(context).brightness == Brightness.dark;

    // Background & text color based on reader theme (Light, Sepia, Dark)
    Color bgColor;
    Color textColor;
    Color cardBg;
    Color subtitleColor;

    switch (themeMode) {
      case ReaderThemeMode.sepia:
        bgColor = const Color(0xFFFBF0D9); // warm cozy paper
        textColor = const Color(0xFF2C241D);
        cardBg = const Color(0xFFF3E5C8);
        subtitleColor = const Color(0xFF5A4A3B);
        break;
      case ReaderThemeMode.dark:
        bgColor = const Color(0xFF0F172A); // deep slate
        textColor = const Color(0xFFE2E8F0);
        cardBg = const Color(0xFF1E293B);
        subtitleColor = const Color(0xFF94A3B8);
        break;
      case ReaderThemeMode.light:
        bgColor = isDarkSystem ? const Color(0xFF0F172A) : const Color(0xFFFCFDFE);
        textColor = isDarkSystem ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);
        cardBg = isDarkSystem ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        subtitleColor = isDarkSystem ? const Color(0xFF94A3B8) : const Color(0xFF475569);
        break;
    }

    final previousScore = readingProvider.getArticleScore(widget.article.id);
    final isStory = widget.article.type == ArticleType.story;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isStory ? '📖 Lingo Story' : '🗞️ The Global Gazette',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: _readingProgress,
            backgroundColor: textColor.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(
              isStory ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
            ),
            minHeight: 3,
          ),
        ),
        actions: [
          // Theme Switcher (White, Sepia, Dark)
          PopupMenuButton<ReaderThemeMode>(
            icon: Icon(
              themeMode == ReaderThemeMode.sepia
                  ? Icons.menu_book_rounded
                  : (themeMode == ReaderThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded),
              color: textColor,
              size: 20,
            ),
            tooltip: 'Okuma Teması',
            onSelected: (mode) {
              readingProvider.setReaderTheme(mode);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ReaderThemeMode.light,
                child: Row(
                  children: [
                    Icon(Icons.light_mode_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Beyaz Tema'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ReaderThemeMode.sepia,
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 18, color: Color(0xFF8D6E63)),
                    SizedBox(width: 8),
                    Text('Sıcak Kağıt (Sepia)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ReaderThemeMode.dark,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Gece Teması'),
                  ],
                ),
              ),
            ],
          ),

          // Saved Words Chip
          Consumer<VocabularyProvider>(
            builder: (context, vocab, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${vocab.words.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Font Size Adjuster
          IconButton(
            icon: Icon(Icons.format_size_rounded, color: textColor),
            tooltip: 'Yazı Boyutu',
            onPressed: () {
              _showFontSizeDialog(context, readingProvider, textColor);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Metadata Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isStory
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : const Color(0xFF4F46E5).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.article.category.toUpperCase(),
                        style: TextStyle(
                          color: isStory ? const Color(0xFF059669) : const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SEVİYE: ${widget.article.level}',
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.schedule_rounded, size: 14, color: subtitleColor),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.article.readTimeMinutes} dk okuma',
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Hero Cover Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.article.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: isDarkSystem ? const Color(0xFF1E293B) : const Color(0xFFEDF2F7),
                              child: const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isStory
                                    ? [const Color(0xFF065F46), const Color(0xFF047857)]
                                    : [const Color(0xFF312E81), const Color(0xFF4338CA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(widget.article.iconEmoji, style: const TextStyle(fontSize: 60)),
                            ),
                          ),
                        ),
                        // Bottom credit overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.camera_alt_outlined, size: 13, color: Colors.white70),
                                const SizedBox(width: 5),
                                Text(
                                  widget.article.authorOrSource,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (isStory ? const Color(0xFF059669) : const Color(0xFF4F46E5))
                                        .withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${widget.article.readTimeMinutes} dk okuma',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Article Title (Editorial Typography)
                Text(
                  widget.article.title,
                  style: GoogleFonts.merriweather(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle / Deck
                Text(
                  widget.article.subtitle,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                    color: subtitleColor,
                  ),
                ),

                const SizedBox(height: 12),

                // Source & Date Byline
                Row(
                  children: [
                    Text(
                      widget.article.authorOrSource,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: subtitleColor,
                      ),
                    ),
                    Text(' • ', style: TextStyle(color: subtitleColor)),
                    Text(
                      '${widget.article.date.day}.${widget.article.date.month}.${widget.article.date.year}',
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                  ],
                ),

                Divider(height: 36, color: textColor.withValues(alpha: 0.12)),

                // Interactive Hint Bar
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: textColor.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 18,
                        color: isStory ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'İpucu: Kelimelerin üstüne gelince sarı parıldar. Tıkla ve hemen haznene ekle! Metin bitince anlama testini çöz.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: textColor.withValues(alpha: 0.9),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Paragraphs (with interactive words and eye-rest mid-article highlight)
                for (int i = 0; i < widget.article.paragraphs.length; i++) ...[
                  InteractiveParagraph(
                    text: widget.article.paragraphs[i],
                    fontSize: readingProvider.fontSize,
                    article: widget.article,
                  ),
                  const SizedBox(height: 18),
                  // Eye-break callout card halfway through
                  if (i == (widget.article.paragraphs.length ~/ 2) - 1)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border(
                          left: BorderSide(
                            color: isStory ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 24,
                            color: isStory ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Göz Dinlendirme & Kelime Notu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isStory ? const Color(0xFF059669) : const Color(0xFF4F46E5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Metindeki bilinmeyen kelimelerin üzerine geldiğinde sarı ışık yanar. Üzerine tıkla ve tek tuşla haznene ekle!',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: textColor.withValues(alpha: 0.85),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],

                const SizedBox(height: 28),

                // Comprehension Quiz Callout Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isStory
                          ? [
                              const Color(0xFF064E3B),
                              const Color(0xFF047857),
                            ]
                          : [
                              const Color(0xFF312E81),
                              const Color(0xFF4F46E5),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: (isStory ? const Color(0xFF059669) : const Color(0xFF4F46E5))
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          size: 36,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Okuduğunu Anladın mı?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bu metin hakkında hazırlanan ${widget.article.quizQuestions.length} kavrama sorusunu çözerek anlama seviyeni test et.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.35,
                        ),
                      ),
                      if (previousScore != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🌟 En Yüksek Skorun: %$previousScore',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizScreen(article: widget.article),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded, color: Color(0xFF4F46E5)),
                          label: Text(
                            previousScore != null
                                ? 'Testi Tekrar Çöz'
                                : 'Anlama Testini Başlat',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog(
      BuildContext context, ReadingProvider readingProvider, Color textColor) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentSize = readingProvider.fontSize;
            return AlertDialog(
              title: const Text(
                'Yazı Boyutu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('A', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Slider(
                          value: currentSize,
                          min: 14.0,
                          max: 26.0,
                          divisions: 6,
                          label: '${currentSize.toInt()} pt',
                          onChanged: (val) {
                            readingProvider.setFontSize(val);
                            setDialogState(() {});
                          },
                        ),
                      ),
                      const Text('A',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(
                    'The quick brown fox jumps over the lazy dog. (${currentSize.toInt()} pt)',
                    style: TextStyle(
                      fontSize: currentSize,
                      fontFamily: 'serif',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Tamam'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
