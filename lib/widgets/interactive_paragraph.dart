import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/reading_provider.dart';
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
  bool _isSelected = false;

  void _showWordBottomSheet(BuildContext context) {
    if (mounted) {
      setState(() {
        _isSelected = true;
      });
    }

    final readingProv = context.read<ReadingProvider>();
    readingProv.registerWordTapped(widget.word);

    var definition = DictionaryService.lookup(widget.word);
    final sentence = _extractSentence(widget.word, widget.fullParagraph);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            if (definition.turkishMeaning == 'Anlam yükleniyor...') {
              DictionaryService.lookupAsync(widget.word).then((resolved) {
                if (modalContext.mounted) {
                  setModalState(() {
                    definition = resolved;
                  });
                }
              });
            }

            return Consumer<VocabularyProvider>(
              builder: (context, vocab, child) {
                final isSaved = vocab.isWordSaved(widget.word);
                return Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E222D) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.word,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                                color: isDark ? Colors.indigo[200] : Colors.indigo[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // PARILDAYAN SARI VURGULU TÜRKÇE ANLAM KARTI
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF451A03), const Color(0xFF78350F)]
                                : [const Color(0xFFFEF08A), const Color(0xFFFDE047)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.shade700,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.40),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.translate_rounded, size: 22, color: Colors.black87),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🌟 TÜRKÇE ANLAMI',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: isDark ? const Color(0xFFFCD34D) : const Color(0xFF78350F),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    definition.turkishMeaning,
                                    style: TextStyle(
                                      fontSize: 19.5,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? const Color(0xFFFFFBEB) : const Color(0xFF451A03),
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (sentence.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Text(
                          'Metin İçi Bağlam:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
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
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _isSelected = false;
        });
      }
      readingProv.setActiveSelectedWord(null);
    });
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
    final reading = context.watch<ReadingProvider>();
    final clean = DictionaryService.cleanWord(widget.word);
    final isSaved = vocab.isWordSaved(widget.word);
    final isTapped = reading.isWordTapped(widget.word);
    final isActive = _isSelected || _isHovered || reading.activeSelectedWord == clean;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTargetKeyWord = reading.highlightKeyWords && (clean.length > 3 || isSaved || isTapped);

    Color wordColor;
    BoxDecoration boxDeco;

    if (isActive) {
      wordColor = isDark ? const Color(0xFFFEF08A) : const Color(0xFF451A03);
      boxDeco = BoxDecoration(
        color: const Color(0xFFFDE047),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD97706), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.85),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      );
    } else if (isSaved) {
      wordColor = isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E);
      boxDeco = BoxDecoration(
        color: Colors.amber.withValues(alpha: isDark ? 0.35 : 0.30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber.shade700, width: 1.2),
      );
    } else if (isTapped) {
      wordColor = isDark ? const Color(0xFFFEF08A) : const Color(0xFF78350F);
      boxDeco = BoxDecoration(
        color: Colors.amber.withValues(alpha: isDark ? 0.28 : 0.24),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 1.0),
      );
    } else if (isTargetKeyWord) {
      wordColor = isDark ? Colors.grey[200]! : const Color(0xFF1E293B);
      boxDeco = BoxDecoration(
        color: isDark ? Colors.amber.withValues(alpha: 0.12) : const Color(0xFFFEF3C7).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(4),
        border: Border(bottom: BorderSide(color: Colors.amber.shade500.withValues(alpha: 0.8), width: 1.6)),
      );
    } else {
      wordColor = isDark ? Colors.grey[200]! : const Color(0xFF1E293B);
      boxDeco = const BoxDecoration(color: Colors.transparent);
    }

    return MouseRegion(
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
        onTapDown: (_) {
          if (mounted) {
            setState(() {
              _isSelected = true;
            });
          }
        },
        onTapCancel: () {
          if (mounted && !_isSelected) {
            setState(() {
              _isSelected = false;
            });
          }
        },
        onTap: () {
          _showWordBottomSheet(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
          decoration: boxDeco,
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
                  fontWeight: (isActive || isSaved)
                      ? FontWeight.w800
                      : (isTapped ? FontWeight.w600 : FontWeight.normal),
                  color: wordColor,
                  decoration: (isSaved && !isActive) ? TextDecoration.underline : null,
                  decorationColor: Colors.amber.shade700,
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
