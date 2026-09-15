import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/vocabulary_provider.dart';
import '../services/dictionary_service.dart';

class InteractiveParagraph extends StatelessWidget {
  final String text;
  final double fontSize;
  final Article article;

  const InteractiveParagraph({
    super.key,
    required this.text,
    required this.fontSize,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    // Break paragraph into word and non-word tokens
    // We match words and their trailing punctuation together to wrap naturally
    final tokens = _tokenize(text);

    return Padding(
      padding: const EdgeInsets.only(bottom: 22.0),
      child: Wrap(
        spacing: 3.5,
        runSpacing: 7.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: tokens.map((token) {
          if (token.isWord) {
            return _InteractiveWordChip(
              word: token.wordPart,
              punctuation: token.punctPart,
              fontSize: fontSize,
              article: article,
              fullParagraph: text,
            );
          } else {
            return Text(
              token.raw,
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: 'serif',
                height: 1.5,
              ),
            );
          }
        }).toList(),
      ),
    );
  }

  List<_Token> _tokenize(String input) {
    final list = <_Token>[];
    // Split by whitespace
    final rawTokens = input.split(RegExp(r'\s+'));
    for (final raw in rawTokens) {
      if (raw.isEmpty) continue;
      // Match leading punctuation, core word (including contractions like don't, it's), and trailing punctuation
      final match = RegExp(r"^([^a-zA-Z0-9]*)([a-zA-Z0-9\-]+(?:'[a-zA-Z0-9]+)?)([^a-zA-Z0-9]*)$").firstMatch(raw);
      if (match != null) {
        final leadingPunct = match.group(1) ?? '';
        final word = match.group(2) ?? '';
        final trailingPunct = match.group(3) ?? '';
        list.add(_Token(
          raw: raw,
          isWord: true,
          wordPart: word,
          punctPart: '$leadingPunct$word$trailingPunct',
          leadingPunct: leadingPunct,
          trailingPunct: trailingPunct,
        ));
      } else {
        list.add(_Token(raw: raw, isWord: false, wordPart: raw, punctPart: raw));
      }
    }
    return list;
  }
}

class _Token {
  final String raw;
  final bool isWord;
  final String wordPart;
  final String punctPart;
  final String leadingPunct;
  final String trailingPunct;

  _Token({
    required this.raw,
    required this.isWord,
    required this.wordPart,
    required this.punctPart,
    this.leadingPunct = '',
    this.trailingPunct = '',
  });
}

class _InteractiveWordChip extends StatefulWidget {
  final String word;
  final String punctuation;
  final double fontSize;
  final Article article;
  final String fullParagraph;

  const _InteractiveWordChip({
    required this.word,
    required this.punctuation,
    required this.fontSize,
    required this.article,
    required this.fullParagraph,
  });

  @override
  State<_InteractiveWordChip> createState() => _InteractiveWordChipState();
}

class _InteractiveWordChipState extends State<_InteractiveWordChip> {
  bool _isHovered = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showFloatingActionCard(BuildContext context) {
    _removeOverlay();

    var definition = DictionaryService.lookup(widget.word);
    final sentence = _extractSentence(widget.word, widget.fullParagraph);

    final renderBox = context.findRenderObject() as RenderBox?;
    final screenSize = MediaQuery.of(context).size;
    Offset calculatedOffset = const Offset(-20, -118);

    if (renderBox != null && renderBox.hasSize) {
      final pos = renderBox.localToGlobal(Offset.zero);
      // If near the top of viewport (e.g. less than 135px from top), open below the word
      final showBelow = pos.dy < 135;
      final dy = showBelow ? (renderBox.size.height + 8.0) : -118.0;

      // Adjust horizontal offset so the 310px card stays fully inside screen width
      double dx = -20.0;
      if (pos.dx + 310 > screenSize.width - 16) {
        dx = (screenSize.width - 16) - (pos.dx + 310);
      }
      if (pos.dx + dx < 16) {
        dx = 16 - pos.dx;
      }
      calculatedOffset = Offset(dx, dy);
    }

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        return StatefulBuilder(
          builder: (overlayContext, setOverlayState) {
            // If definition is pending async lookup, trigger it and update overlay when ready
            if (definition.turkishMeaning == 'Anlam yükleniyor...') {
              DictionaryService.lookupAsync(widget.word).then((resolved) {
                if (_overlayEntry != null && mounted) {
                  setOverlayState(() {
                    definition = resolved;
                  });
                }
              });
            }

            return Stack(
              children: [
                // Click outside to dismiss
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _removeOverlay();
                      if (mounted) setState(() {});
                    },
                  ),
                ),
                // Floating Card anchored safely near the word
                Positioned(
                  width: 310,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: calculatedOffset,
                    child: Consumer<VocabularyProvider>(
                      builder: (context, vocab, child) {
                        final isSaved = vocab.isWordSaved(widget.word);
                        final isDark = Theme.of(context).brightness == Brightness.dark;

                        return Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(16),
                          color: isDark ? const Color(0xFF1E222D) : Colors.white,
                          shadowColor: Colors.amber.withValues(alpha: 0.35),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.8),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Word + Turkish meaning
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.word,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: isDark ? Colors.amber[300] : Colors.amber[900],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        definition.turkishMeaning,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.5,
                                          color: isDark ? Colors.grey[100] : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _removeOverlay();
                                        if (mounted) setState(() {});
                                      },
                                      child: Icon(Icons.close_rounded,
                                          size: 18, color: Colors.grey[400]),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Direct Action Button: "Kelime Hazneme Ekle"
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          if (isSaved) {
                                            vocab.removeWord(widget.word);
                                          } else {
                                            vocab.addWord(
                                              rawWord: widget.word,
                                              meaning: definition.turkishMeaning,
                                              contextSentence: sentence,
                                              articleTitle: widget.article.title,
                                            );
                                          }
                                          _removeOverlay();
                                          if (mounted) setState(() {});

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(isSaved
                                                  ? '"${widget.word}" hazneden çıkarıldı.'
                                                  : '⭐ "${widget.word}" kelime haznene eklendi!'),
                                              backgroundColor:
                                                  isSaved ? Colors.grey[800] : const Color(0xFF10B981),
                                              behavior: SnackBarBehavior.floating,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          isSaved
                                              ? Icons.bookmark_added_rounded
                                              : Icons.bookmark_add_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          isSaved ? 'Hazneden Çıkar' : 'Kelime Hazneme Ekle',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSaved
                                              ? Colors.redAccent[400]
                                              : const Color(0xFF4F46E5),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.info_outline_rounded, size: 20),
                                      tooltip: 'Tam Detay & Cümle',
                                      onPressed: () {
                                        _removeOverlay();
                                        _showFullDetailBottomSheet(context, definition, sentence);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _showFullDetailBottomSheet(
      BuildContext context, WordDefinition definition, String sentence) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Consumer<VocabularyProvider>(
          builder: (context, vocab, child) {
            final isSaved = vocab.isWordSaved(widget.word);
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E222D) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.word,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (definition.phonetic != null)
                        Text(
                          definition.phonetic!,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.indigoAccent[200],
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          definition.partOfSpeech,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF282F3F) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      definition.turkishMeaning,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (sentence.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('Metin İçi Bağlam:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border(left: BorderSide(color: Colors.amber[700]!, width: 3)),
                      ),
                      child: Text(
                        '"$sentence"',
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (isSaved) {
                          vocab.removeWord(widget.word);
                        } else {
                          vocab.addWord(
                            rawWord: widget.word,
                            meaning: definition.turkishMeaning,
                            contextSentence: sentence,
                            articleTitle: widget.article.title,
                          );
                        }
                        Navigator.pop(sheetContext);
                      },
                      icon: Icon(
                        isSaved ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        isSaved ? 'Hazneden Çıkar' : 'Kelime Hazneme Ekle',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSaved ? Colors.redAccent : const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _extractSentence(String targetWord, String paragraph) {
    final cleanTarget = DictionaryService.cleanWord(targetWord);
    if (cleanTarget.isEmpty) return paragraph;
    final sentences = paragraph.split(RegExp(r'(?<=[.?!])\s+'));
    final wordRegex = RegExp(r'\b' + RegExp.escape(cleanTarget) + r'\b', caseSensitive: false);
    for (final s in sentences) {
      if (wordRegex.hasMatch(s)) {
        return s.trim();
      }
    }
    for (final s in sentences) {
      if (s.toLowerCase().contains(cleanTarget)) {
        return s.trim();
      }
    }
    return paragraph.length > 120 ? '${paragraph.substring(0, 120)}...' : paragraph;
  }

  @override
  Widget build(BuildContext context) {
    final vocab = context.watch<VocabularyProvider>();
    final isSaved = vocab.isWordSaved(widget.word);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOpened = _overlayEntry != null;

    // Glowing yellow styling on hover or selection!
    final isHighlighted = _isHovered || isOpened;

    Color wordColor;
    if (isSaved) {
      wordColor = isDark ? Colors.amber[300]! : Colors.amber[900]!;
    } else if (isHighlighted) {
      wordColor = const Color(0xFFB45309); // deep golden amber
    } else {
      wordColor = isDark ? Colors.grey[200]! : const Color(0xFF1E293B);
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: GestureDetector(
          onTap: () {
            _showFloatingActionCard(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              // SARI IŞIK / PARILTI VURGUSU (Yellow Glow on Hover & Select)
              color: isHighlighted
                  ? Colors.amber.withValues(alpha: 0.45)
                  : (isSaved
                      ? (isDark
                          ? Colors.amber.withValues(alpha: 0.2)
                          : Colors.amber.withValues(alpha: 0.22))
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isHighlighted
                    ? Colors.amber
                    : (isSaved ? Colors.amber.withValues(alpha: 0.6) : Colors.transparent),
                width: isHighlighted ? 1.5 : 1.0,
              ),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.65),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (tokenLeading(widget.punctuation).isNotEmpty)
                  Text(
                    tokenLeading(widget.punctuation),
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontFamily: 'serif',
                      color: isDark ? Colors.grey[400] : const Color(0xFF1E293B),
                    ),
                  ),
                Text(
                  widget.word,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontFamily: 'serif',
                    fontWeight:
                        (isSaved || isHighlighted) ? FontWeight.w700 : FontWeight.normal,
                    color: wordColor,
                    decoration: isSaved ? TextDecoration.underline : null,
                    decorationColor: Colors.amber,
                    decorationThickness: 1.5,
                  ),
                ),
                if (tokenTrailing(widget.punctuation).isNotEmpty)
                  Text(
                    tokenTrailing(widget.punctuation),
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontFamily: 'serif',
                      color: isDark ? Colors.grey[400] : const Color(0xFF1E293B),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String tokenLeading(String raw) {
    final idx = raw.indexOf(widget.word);
    if (idx > 0) return raw.substring(0, idx);
    return '';
  }

  String tokenTrailing(String raw) {
    final idx = raw.indexOf(widget.word);
    if (idx >= 0 && idx + widget.word.length < raw.length) {
      return raw.substring(idx + widget.word.length);
    }
    return '';
  }
}
