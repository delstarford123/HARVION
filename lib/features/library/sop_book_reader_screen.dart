import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import 'book_model.dart';
import 'data/sop_chapters_repository.dart';
import 'services/online_reader_service.dart';

enum ReaderTheme { light, night, sepia, cream }
enum ReaderViewMode { paginated, continuous }

class SopBookReaderScreen extends StatefulWidget {
  final Book book;

  const SopBookReaderScreen({super.key, required this.book});

  @override
  State<SopBookReaderScreen> createState() => _SopBookReaderScreenState();
}

class _SopBookReaderScreenState extends State<SopBookReaderScreen> {
  int _selectedChapterIndex = 0;
  int _currentPageIndex = 0;
  double _fontSize = 17.0;
  final double _lineHeight = 1.7;
  String _fontFamily = 'Serif';
  ReaderTheme _readerTheme = ReaderTheme.light;
  ReaderViewMode _viewMode = ReaderViewMode.paginated;
  bool _isPlayingAudio = false;

  final TextEditingController _chapterSearchController = TextEditingController();
  String _chapterSearchQuery = '';
  late PageController _pageController;

  late final List<Map<String, dynamic>> _allChapters;
  final Set<String> _bookmarkedPages = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _allChapters = SopChaptersRepository.getChaptersForBook(widget.book.id, widget.book.title);
    _restoreReadingProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chapterSearchController.dispose();
    super.dispose();
  }

  String get _storageKey => 'read_progress_${widget.book.id}';
  String get _bookmarksKey => 'bookmarks_${widget.book.id}';

  void _restoreReadingProgress() {
    try {
      if (Hive.isBoxOpen(AppConstants.boxSavedArticles)) {
        final box = Hive.box(AppConstants.boxSavedArticles);
        final savedData = box.get(_storageKey);
        if (savedData is Map) {
          final ch = savedData['chapter'] as int? ?? 0;
          final pg = savedData['page'] as int? ?? 0;
          if (ch < _allChapters.length) {
            _selectedChapterIndex = ch;
            final currentChapter = _allChapters[_selectedChapterIndex];
            final pages = SopChaptersRepository.getPagesForChapter(currentChapter);
            _currentPageIndex = pg < pages.length ? pg : 0;
          }
        }
        final savedBookmarks = box.get(_bookmarksKey);
        if (savedBookmarks is List) {
          _bookmarkedPages.addAll(savedBookmarks.map((e) => e.toString()));
        }
      }
    } catch (_) {}
  }

  void _saveReadingProgress() {
    try {
      if (Hive.isBoxOpen(AppConstants.boxSavedArticles)) {
        final box = Hive.box(AppConstants.boxSavedArticles);
        box.put(_storageKey, {
          'chapter': _selectedChapterIndex,
          'page': _currentPageIndex,
          'timestamp': DateTime.now().toIso8601String(),
        });
        box.put(_bookmarksKey, _bookmarkedPages.toList());
      }
    } catch (_) {}
  }

  void _toggleBookmark(int chapterIdx, int pageIdx) {
    final key = 'ch_${chapterIdx}_pg_$pageIdx';
    setState(() {
      if (_bookmarkedPages.contains(key)) {
        _bookmarkedPages.remove(key);
      } else {
        _bookmarkedPages.add(key);
      }
    });
    _saveReadingProgress();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_bookmarkedPages.contains(key)
            ? 'Page ${pageIdx + 1} Bookmarked!'
            : 'Bookmark removed.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _goToChapter(int chapterIndex, {int pageIndex = 0}) {
    if (chapterIndex >= 0 && chapterIndex < _allChapters.length) {
      setState(() {
        _selectedChapterIndex = chapterIndex;
        _currentPageIndex = pageIndex;
      });
      _saveReadingProgress();
      if (_viewMode == ReaderViewMode.paginated && _pageController.hasClients) {
        _pageController.jumpToPage(pageIndex);
      }
    }
  }

  void _goToPage(int pageIndex, int totalPages) {
    if (pageIndex >= 0 && pageIndex < totalPages) {
      setState(() {
        _currentPageIndex = pageIndex;
      });
      _saveReadingProgress();
      if (_viewMode == ReaderViewMode.paginated && _pageController.hasClients) {
        _pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _showJumpToPageDialog(int totalPages) {
    final controller = TextEditingController(text: '${_currentPageIndex + 1}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jump to Page', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter page number (1 to $totalPages):'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pages),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val >= 1 && val <= totalPages) {
                Navigator.pop(ctx);
                _goToPage(val - 1, totalPages);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  void _showBookmarksSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        if (_bookmarkedPages.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No bookmarks saved yet.\\nTap the bookmark icon on any page to save it for quick access.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Saved Bookmarks',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),
            ..._bookmarkedPages.map((key) {
              final parts = key.split('_');
              final chIdx = int.tryParse(parts[1]) ?? 0;
              final pgIdx = int.tryParse(parts[3]) ?? 0;
              final ch = _allChapters[chIdx];
              return ListTile(
                leading: const Icon(Icons.bookmark, color: AppTheme.sacredGold),
                title: Text(ch['title'] ?? 'Chapter ${chIdx + 1}'),
                subtitle: Text('Page ${pgIdx + 1}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  _goToChapter(chIdx, pageIndex: pgIdx);
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _openOnlineReader() {
    OnlineReaderService.openOnlineBook(
      context,
      widget.book.effectiveOnlineUrl,
      title: widget.book.title,
    );
  }

  Color _getBackgroundColor() {
    switch (_readerTheme) {
      case ReaderTheme.night:
        return const Color(0xFF121212);
      case ReaderTheme.sepia:
        return const Color(0xFFFBF0D9);
      case ReaderTheme.cream:
        return const Color(0xFFF7F4EA);
      case ReaderTheme.light:
        return const Color(0xFFFAF9F6);
    }
  }

  Color _getTextColor() {
    switch (_readerTheme) {
      case ReaderTheme.night:
        return const Color(0xFFE2E8F0);
      case ReaderTheme.sepia:
        return const Color(0xFF3E2723);
      case ReaderTheme.cream:
        return const Color(0xFF2D3748);
      case ReaderTheme.light:
        return const Color(0xFF1A202C);
    }
  }

  Color _getCardColor() {
    switch (_readerTheme) {
      case ReaderTheme.night:
        return const Color(0xFF1E1E1E);
      case ReaderTheme.sepia:
        return const Color(0xFFF4E4C1);
      case ReaderTheme.cream:
        return const Color(0xFFEDE6D6);
      case ReaderTheme.light:
        return Colors.white;
    }
  }

  TextStyle _getPageTextStyle() {
    final color = _getTextColor();
    switch (_fontFamily) {
      case 'Sans':
        return TextStyle(
          fontSize: _fontSize,
          height: _lineHeight,
          color: color,
          fontFamily: 'Inter',
        );
      case 'Mono':
        return TextStyle(
          fontSize: _fontSize - 1,
          height: _lineHeight,
          color: color,
          fontFamily: 'monospace',
        );
      case 'Serif':
      default:
        return TextStyle(
          fontSize: _fontSize,
          height: _lineHeight,
          color: color,
          fontFamily: 'Merriweather',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _allChapters[_selectedChapterIndex];
    final totalChapters = _allChapters.length;
    final title = chapter['title'] as String? ?? 'Chapter ${_selectedChapterIndex + 1}';
    final subtitle = chapter['subtitle'] as String? ?? '';
    final scripture = chapter['scripture'] as String? ?? '';
    final pages = SopChaptersRepository.getPagesForChapter(chapter);
    final totalPagesInChapter = pages.length;
    final totalBookPages = SopChaptersRepository.getTotalPagesForBook(widget.book.id, widget.book.title);

    final isBookmarked = _bookmarkedPages.contains('ch_${_selectedChapterIndex}_pg_$_currentPageIndex');
    final progressPercent = ((_selectedChapterIndex + 1) / totalChapters * 100).toInt();

    final bgColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final cardColor = _getCardColor();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Ch. ${_selectedChapterIndex + 1}/$totalChapters • Pg. ${_currentPageIndex + 1}/$totalPagesInChapter ($progressPercent% Done)',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Audio Read-Aloud Toggle
          IconButton(
            tooltip: _isPlayingAudio ? 'Pause Narration' : 'Listen to Chapter',
            icon: Icon(_isPlayingAudio ? Icons.pause_circle : Icons.volume_up, size: 21),
            onPressed: () {
              setState(() {
                _isPlayingAudio = !_isPlayingAudio;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isPlayingAudio
                      ? 'Audio Read-Aloud Activated for: $title'
                      : 'Narration paused.'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          // Bookmark Page
          IconButton(
            tooltip: isBookmarked ? 'Remove Bookmark' : 'Bookmark Page',
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppTheme.sacredGold : Colors.white,
              size: 21,
            ),
            onPressed: () => _toggleBookmark(_selectedChapterIndex, _currentPageIndex),
          ),
          // View Bookmarks
          IconButton(
            tooltip: 'View Bookmarks',
            icon: const Icon(Icons.collections_bookmark_outlined, size: 20),
            onPressed: _showBookmarksSheet,
          ),
          // Read Online on EGW Writings
          IconButton(
            tooltip: 'Read Online (EGW Writings)',
            icon: const Icon(Icons.public, size: 20),
            onPressed: _openOnlineReader,
          ),
          // Reader Display Settings Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune, size: 20),
            tooltip: 'Reader Settings & Themes',
            onSelected: (val) {
              setState(() {
                if (val == 'theme_light') _readerTheme = ReaderTheme.light;
                if (val == 'theme_night') _readerTheme = ReaderTheme.night;
                if (val == 'theme_sepia') _readerTheme = ReaderTheme.sepia;
                if (val == 'theme_cream') _readerTheme = ReaderTheme.cream;

                if (val == 'font_serif') _fontFamily = 'Serif';
                if (val == 'font_sans') _fontFamily = 'Sans';
                if (val == 'font_mono') _fontFamily = 'Mono';

                if (val == 'mode_paginated') _viewMode = ReaderViewMode.paginated;
                if (val == 'mode_continuous') _viewMode = ReaderViewMode.continuous;

                if (val == 'font_up' && _fontSize < 28) _fontSize += 1.5;
                if (val == 'font_down' && _fontSize > 12) _fontSize -= 1.5;
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(enabled: false, child: Text('🎨 READING THEME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              const PopupMenuItem(value: 'theme_light', child: Text('☀️ Light Theme')),
              const PopupMenuItem(value: 'theme_sepia', child: Text('📜 Warm Sepia')),
              const PopupMenuItem(value: 'theme_cream', child: Text('🥛 Eye Comfort Cream')),
              const PopupMenuItem(value: 'theme_night', child: Text('🌙 AMOLED Night')),
              const PopupMenuDivider(),
              const PopupMenuItem(enabled: false, child: Text('🔤 TYPOGRAPHY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              const PopupMenuItem(value: 'font_serif', child: Text('Classic Serif (Bible)')),
              const PopupMenuItem(value: 'font_sans', child: Text('Modern Sans-Serif')),
              const PopupMenuItem(value: 'font_mono', child: Text('Monospace')),
              const PopupMenuItem(value: 'font_up', child: Text('A+ Enlarge Font')),
              const PopupMenuItem(value: 'font_down', child: Text('A- Reduce Font')),
              const PopupMenuDivider(),
              const PopupMenuItem(enabled: false, child: Text('📖 READING MODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              PopupMenuItem(
                value: _viewMode == ReaderViewMode.paginated ? 'mode_continuous' : 'mode_paginated',
                child: Text(_viewMode == ReaderViewMode.paginated ? 'Switch to Continuous Scroll' : 'Switch to Page Flip Mode'),
              ),
            ],
          ),
        ],
      ),
      // Chapter Selection Drawer
      drawer: Drawer(
        backgroundColor: cardColor,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_stories, color: AppTheme.sacredGold, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    widget.book.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'By ${widget.book.author} • $totalChapters Chapters • ~$totalBookPages Pages',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                  ),
                ],
              ),
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.public, color: AppTheme.sacredGold, size: 20),
              title: const Text('Read Full Book Online (Official EGW)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              trailing: const Icon(Icons.open_in_new, size: 14),
              onTap: () {
                Navigator.pop(context);
                _openOnlineReader();
              },
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: TextField(
                controller: _chapterSearchController,
                onChanged: (val) => setState(() => _chapterSearchQuery = val.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search chapters & topics...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  filled: true,
                  fillColor: _readerTheme == ReaderTheme.night ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _allChapters.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15)),
                itemBuilder: (context, i) {
                  final ch = _allChapters[i];
                  final chTitle = ch['title'] as String? ?? 'Chapter ${i + 1}';
                  final chSub = ch['subtitle'] as String? ?? '';
                  final chPages = SopChaptersRepository.getPagesForChapter(ch);
                  final isSel = i == _selectedChapterIndex;

                  if (_chapterSearchQuery.isNotEmpty) {
                    if (!chTitle.toLowerCase().contains(_chapterSearchQuery) &&
                        !chSub.toLowerCase().contains(_chapterSearchQuery)) {
                      return const SizedBox.shrink();
                    }
                  }

                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: isSel ? AppTheme.sacredGold : Colors.grey.shade200,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.black : Colors.black87,
                        ),
                      ),
                    ),
                    title: Text(
                      chTitle,
                      style: TextStyle(
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                        color: isSel ? AppTheme.primaryGreen : textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${chPages.length} pages • ${chSub.isNotEmpty ? chSub : 'Present truth'}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      _goToChapter(i);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Main Body: Paginated View or Continuous View
      body: _viewMode == ReaderViewMode.paginated
          ? _buildPaginatedView(chapter, pages, title, subtitle, scripture, totalPagesInChapter, textColor, cardColor)
          : _buildContinuousView(chapter, pages, title, subtitle, scripture, totalPagesInChapter, textColor, cardColor),
      // Bottom Bar with Page Navigation, Counter, and Quick Sliders
      bottomNavigationBar: _buildBottomPageBar(totalPagesInChapter, totalChapters, textColor, cardColor),
    );
  }

  // ==========================================
  // 📖 MODE 1: PAGINATED PAGE FLIP MODE
  // ==========================================
  Widget _buildPaginatedView(
    Map<String, dynamic> chapter,
    List<String> pages,
    String title,
    String subtitle,
    String scripture,
    int totalPages,
    Color textColor,
    Color cardColor,
  ) {
    return PageView.builder(
      controller: _pageController,
      itemCount: totalPages,
      onPageChanged: (idx) {
        setState(() {
          _currentPageIndex = idx;
        });
        _saveReadingProgress();
      },
      itemBuilder: (context, pageIdx) {
        final pageText = pages[pageIdx];
        final isFirstPage = pageIdx == 0;
        final isLastPage = pageIdx == totalPages - 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header on Page 1
              if (isFirstPage) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'CHAPTER ${_selectedChapterIndex + 1} OF ${_allChapters.length}',
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Page 1 of $totalPages',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _readerTheme == ReaderTheme.night ? Colors.white : AppTheme.primaryBlue,
                    height: 1.25,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Divider(color: Colors.grey.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
              ] else ...[
                // Sub-header for page 2+
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Page ${pageIdx + 1} of $totalPages',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Actual Page Content
              SelectableText(
                pageText,
                style: _getPageTextStyle(),
              ),

              // End of Chapter Extras (Key Scripture, Questions & Online Link)
              if (isLastPage) ...[
                const SizedBox(height: 28),
                if (scripture.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.menu_book, color: AppTheme.sacredGold, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Key Scripture Foundation',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          scripture,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                // Official Online EGW Writings Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.public, color: AppTheme.sacredGold, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Official EGW Writings Online',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'Read with complete original pagination on m.egwwritings.org',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.open_in_browser, size: 16, color: AppTheme.sacredGold),
                          label: const Text('OPEN ONLINE (EGW WRITINGS)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: _openOnlineReader,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 📜 MODE 2: CONTINUOUS SCROLL MODE
  // ==========================================
  Widget _buildContinuousView(
    Map<String, dynamic> chapter,
    List<String> pages,
    String title,
    String subtitle,
    String scripture,
    int totalPages,
    Color textColor,
    Color cardColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'CHAPTER ${_selectedChapterIndex + 1} OF ${_allChapters.length} • $totalPages PAGES',
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _readerTheme == ReaderTheme.night ? Colors.white : AppTheme.primaryBlue,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),

          ...pages.asMap().entries.map((entry) {
            final pageNum = entry.key + 1;
            final text = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Page $pageNum of $totalPages', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                    ),
                    const Expanded(child: Divider(indent: 10)),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(text, style: _getPageTextStyle()),
                const SizedBox(height: 20),
              ],
            );
          }),

          if (scripture.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.5)),
              ),
              child: Text('Scripture: $scripture', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==========================================
  // 🧭 BOTTOM NAVIGATION BAR (PAGE-BY-PAGE)
  // ==========================================
  Widget _buildBottomPageBar(int totalPagesInChapter, int totalChapters, Color textColor, Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            // Previous Chapter / Previous Page
            IconButton(
              tooltip: 'Previous Page',
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              onPressed: _currentPageIndex > 0
                  ? () => _goToPage(_currentPageIndex - 1, totalPagesInChapter)
                  : (_selectedChapterIndex > 0
                      ? () => _goToChapter(_selectedChapterIndex - 1)
                      : null),
            ),
            // Page Indicator Button (Click to Jump)
            Expanded(
              child: InkWell(
                onTap: () => _showJumpToPageDialog(totalPagesInChapter),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Page ${_currentPageIndex + 1} of $totalPagesInChapter',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Ch. ${_selectedChapterIndex + 1}/$totalChapters • Tap to jump',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Next Page / Next Chapter
            IconButton(
              tooltip: 'Next Page',
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: _currentPageIndex < totalPagesInChapter - 1
                  ? () => _goToPage(_currentPageIndex + 1, totalPagesInChapter)
                  : (_selectedChapterIndex < totalChapters - 1
                      ? () => _goToChapter(_selectedChapterIndex + 1)
                      : null),
            ),
            const VerticalDivider(width: 16, indent: 6, endIndent: 6),
            // Share Page
            IconButton(
              tooltip: 'Share Page Quote',
              icon: const Icon(Icons.share, size: 18),
              onPressed: () {
                final ch = _allChapters[_selectedChapterIndex];
                final pages = SopChaptersRepository.getPagesForChapter(ch);
                final pText = pages.isNotEmpty ? pages[_currentPageIndex] : '';
                Share.share(
                  '📖 ${widget.book.title}\n${ch['title']}\nPage ${_currentPageIndex + 1}:\n\n'
                  '$pText\n\n'
                  '🌐 Read Online: ${widget.book.effectiveOnlineUrl}\n'
                  '— Read on Harvion SDA Ministry App',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
