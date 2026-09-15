import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/reading_provider.dart';
import '../providers/vocabulary_provider.dart';
import 'reader_screen.dart';
import 'vocabulary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentNavIndex,
        children: const [
          _NewspaperTab(),
          _StoriesTab(),
          VocabularyScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentNavIndex = idx;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.newspaper_rounded),
            selectedIcon: Icon(Icons.newspaper_rounded, color: Color(0xFF4F46E5)),
            label: 'Gazete Oku',
          ),
          const NavigationDestination(
            icon: Icon(Icons.auto_stories_rounded),
            selectedIcon: Icon(Icons.auto_stories_rounded, color: Color(0xFF4F46E5)),
            label: 'Hikayeler',
          ),
          NavigationDestination(
            icon: Consumer<VocabularyProvider>(
              builder: (context, vocab, _) {
                return Badge(
                  isLabelVisible: vocab.learningWords.isNotEmpty,
                  label: Text('${vocab.learningWords.length}'),
                  child: const Icon(Icons.bookmark_rounded),
                );
              },
            ),
            selectedIcon: const Icon(Icons.bookmark_rounded, color: Color(0xFF4F46E5)),
            label: 'Kelime Haznem',
          ),
        ],
      ),
    );
  }
}

/// ==========================================
/// DEDICATED NEWSPAPER TAB (GAZETE OKUMA BÖLÜMÜ)
/// ==========================================
class _NewspaperTab extends StatefulWidget {
  const _NewspaperTab();

  @override
  State<_NewspaperTab> createState() => _NewspaperTabState();
}

class _NewspaperTabState extends State<_NewspaperTab> {
  String _selectedCategory = 'Tümü';
  String _selectedLevel = 'Tümü';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final reading = context.watch<ReadingProvider>();
    final vocab = context.watch<VocabularyProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allNews = reading.articles.where((a) => a.type == ArticleType.news).toList();

    // Dynamically derive unique categories
    final categorySet = allNews.map((a) => a.category).toSet().toList()..sort();
    final categories = ['Tümü', ...categorySet];
    final levels = ['Tümü', 'A1', 'A2', 'B1', 'B2', 'C1'];

    // Filter by Category, Level, and Search Query
    var newsList = allNews;
    if (_selectedCategory != 'Tümü') {
      newsList = newsList.where((a) => a.category == _selectedCategory).toList();
    }
    if (_selectedLevel != 'Tümü') {
      newsList = newsList.where((a) => a.level == _selectedLevel).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      newsList = newsList.where((a) =>
          a.title.toLowerCase().contains(q) ||
          a.subtitle.toLowerCase().contains(q) ||
          a.category.toLowerCase().contains(q)).toList();
    }

    final headlineArticle = allNews.isNotEmpty
        ? allNews.firstWhere((a) => a.id == 'news_ai_medicine', orElse: () => allNews.first)
        : null;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        '🗞️ The Global Gazette',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                  Text(
                    'Dünya Basınından Güncel Haberler (${allNews.length} Haber)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E222D) : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_rounded, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${vocab.words.length} Kelime',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Featured Headline Banner (Hero)
            if (headlineArticle != null && _searchQuery.isEmpty && _selectedCategory == 'Tümü' && _selectedLevel == 'Tümü')
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          headlineArticle.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1E1B4B), Color(0xFF4F46E5)],
                              ),
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.88),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'GÜNÜN MANŞETİ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      headlineArticle.category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${headlineArticle.readTimeMinutes} dk okuma',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                headlineArticle.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                  shadows: [
                                    Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReaderScreen(article: headlineArticle),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.menu_book_rounded, color: Color(0xFF4F46E5), size: 18),
                                  label: const Text(
                                    'Haberi Oku & Kelimeleri Keşfet',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF4F46E5),
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Live Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Haberlerde ara (başlık, konu veya kelime)...',
                    hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF4F46E5)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E222D) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF2D3343) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),

            // Category & Level Filter Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'Kategoriler (${newsList.length} haber listeleniyor)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E222D) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2D3343) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedLevel,
                            underline: const SizedBox(),
                            isDense: true,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[200] : const Color(0xFF4F46E5),
                            ),
                            items: levels
                                .map((lvl) => DropdownMenuItem(
                                    value: lvl,
                                    child: Text(lvl == 'Tümü' ? 'Tüm Seviyeler' : 'Seviye $lvl')))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedLevel = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                            selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                            checkmarkColor: const Color(0xFF4F46E5),
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF4F46E5)
                                  : (isDark ? Colors.grey[300] : Colors.grey[700]),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Empty state or Responsive 3-Column Magazine Grid
            if (newsList.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 52, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Aramanıza veya seçilen filtrelere uygun haber bulunamadı.',
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = 'Tümü';
                              _selectedLevel = 'Tümü';
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Tüm Haberleri Göster'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 380,
                    mainAxisSpacing: 22,
                    crossAxisSpacing: 22,
                    mainAxisExtent: 460,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = newsList[index];
                      final score = reading.getArticleScore(article.id);
                      return _buildArticleCard(context, article, score, isDark);
                    },
                    childCount: newsList.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ==========================================
/// DEDICATED STORIES TAB (KISA HİKAYELER BÖLÜMÜ)
/// ==========================================
class _StoriesTab extends StatefulWidget {
  const _StoriesTab();

  @override
  State<_StoriesTab> createState() => _StoriesTabState();
}

class _StoriesTabState extends State<_StoriesTab> {
  String _selectedCategory = 'Tümü';
  String _selectedLevel = 'Tümü';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final reading = context.watch<ReadingProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allStories = reading.articles.where((a) => a.type == ArticleType.story).toList();

    // Dynamically derive unique story categories
    final categorySet = allStories.map((a) => a.category).toSet().toList()..sort();
    final categories = ['Tümü', ...categorySet];
    final levels = ['Tümü', 'A1', 'A2', 'B1', 'B2', 'C1'];

    var storiesList = allStories;
    if (_selectedCategory != 'Tümü') {
      storiesList = storiesList.where((a) => a.category == _selectedCategory).toList();
    }
    if (_selectedLevel != 'Tümü') {
      storiesList = storiesList.where((a) => a.level == _selectedLevel).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      storiesList = storiesList.where((a) =>
          a.title.toLowerCase().contains(q) ||
          a.subtitle.toLowerCase().contains(q) ||
          a.category.toLowerCase().contains(q)).toList();
    }

    final featuredStory = allStories.isNotEmpty
        ? allStories.firstWhere((a) => a.id == 'story_neon_violin', orElse: () => allStories.first)
        : null;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📚 Lingo Stories',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  Text(
                    'Kısa Hikayeler & Edebi Metinler (${allStories.length} Hikaye)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),

            // Featured Story Photo Banner
            if (featuredStory != null && _searchQuery.isEmpty && _selectedCategory == 'Tümü' && _selectedLevel == 'Tümü')
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF059669).withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          featuredStory.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF064E3B), Color(0xFF059669)],
                              ),
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.25),
                                Colors.black.withValues(alpha: 0.88),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'ÖNE ÇIKAN HİKAYE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      featuredStory.category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${featuredStory.readTimeMinutes} dk okuma',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                featuredStory.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                  shadows: [
                                    Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReaderScreen(article: featuredStory),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.auto_stories_rounded, color: Color(0xFF059669), size: 18),
                                  label: const Text(
                                    'Hikayeyi Oku & Testi Çöz',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF059669),
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Live Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Hikayelerde ara (başlık, tür veya kelime)...',
                    hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF059669)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E222D) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF2D3343) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),

            // Category & Level Filter Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'Türler (${storiesList.length} hikaye listeleniyor)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E222D) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2D3343) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedLevel,
                            underline: const SizedBox(),
                            isDense: true,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey[200] : const Color(0xFF059669),
                            ),
                            items: levels
                                .map((lvl) => DropdownMenuItem(
                                    value: lvl,
                                    child: Text(lvl == 'Tümü' ? 'Tüm Seviyeler' : 'Seviye $lvl')))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedLevel = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                            selectedColor: const Color(0xFF059669).withValues(alpha: 0.15),
                            checkmarkColor: const Color(0xFF059669),
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF059669)
                                  : (isDark ? Colors.grey[300] : Colors.grey[700]),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Empty state or Responsive 3-Column Magazine Grid
            if (storiesList.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 52, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Aramanıza veya seçilen filtrelere uygun hikaye bulunamadı.',
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = 'Tümü';
                              _selectedLevel = 'Tümü';
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Tüm Hikayeleri Göster'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 380,
                    mainAxisSpacing: 22,
                    crossAxisSpacing: 22,
                    mainAxisExtent: 460,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = storiesList[index];
                      final score = reading.getArticleScore(article.id);
                      return _buildArticleCard(context, article, score, isDark);
                    },
                    childCount: storiesList.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _buildArticleCard(
    BuildContext context, Article article, int? score, bool isDark) {
  final isStory = article.type == ArticleType.story;

  // Level color palette
  Color getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
      case 'A2':
        return const Color(0xFF059669); // Emerald
      case 'B1':
        return const Color(0xFF2563EB); // Royal Blue
      case 'B2':
        return const Color(0xFF7C3AED); // Purple
      case 'C1':
      case 'C2':
        return const Color(0xFFD97706); // Amber / Orange
      default:
        return const Color(0xFF4F46E5);
    }
  }

  final levelColor = getLevelColor(article.level);

  return Container(
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E222D) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? const Color(0xFF2D3343) : const Color(0xFFE2E8F0),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        hoverColor: (isStory ? const Color(0xFF059669) : const Color(0xFF4F46E5)).withValues(alpha: 0.04),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReaderScreen(article: article),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Image with floating badges
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              child: SizedBox(
                height: 185,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      article.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: isDark ? const Color(0xFF262C3A) : const Color(0xFFEDF2F7),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
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
                            child: Text(article.iconEmoji, style: const TextStyle(fontSize: 46)),
                          ),
                        );
                      },
                    ),
                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                    // Top Badges
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(article.iconEmoji, style: const TextStyle(fontSize: 12.5)),
                                const SizedBox(width: 5),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 130),
                                  child: Text(
                                    article.category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: levelColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              'Seviye ${article.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom-right reading time
                    Positioned(
                      bottom: 8,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${article.readTimeMinutes} dk',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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

            // 2. Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (score != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: score >= 75
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  score >= 75
                                      ? Icons.check_circle_rounded
                                      : Icons.help_outline_rounded,
                                  size: 13,
                                  color: score >= 75 ? Colors.green : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Test: %$score',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: score >= 75
                                        ? Colors.green[700]
                                        : Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Row(
                            children: [
                              Icon(
                                Icons.quiz_outlined,
                                size: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${article.quizQuestions.length} Soru Test',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(
                            color: isStory
                                ? const Color(0xFF059669).withValues(alpha: 0.12)
                                : const Color(0xFF4F46E5).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Oku & Test',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isStory
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF4F46E5),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: isStory
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF4F46E5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
