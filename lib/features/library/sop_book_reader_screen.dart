import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/services/sda_voice_narration_service.dart';
import '../../core/widgets/sda_voice_audio_player_bar.dart';
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

  final TextEditingController _chapterSearchController = TextEditingController();
  String _chapterSearchQuery = '';
  late PageController _pageController;

  late final List<Map<String, dynamic>> _allChapters;
  final Set<String> _bookmarkedPages = {};

  int _speakingParagraphIndex = -1;

  void _startSopVoiceNarration([int startIndex = 0]) {
    final currentChapter = _allChapters[_selectedChapterIndex];
    final pages = SopChaptersRepository.getPagesForChapter(currentChapter);
    final currentPageText = _currentPageIndex < pages.length ? pages[_currentPageIndex] : '';
    final chapterTitle = currentChapter['title'] as String? ?? 'Chapter ${_selectedChapterIndex + 1}';

    // Split page text into distinct paragraphs
    final rawParagraphs = currentPageText.split(RegExp(r'\n+'));
    final paragraphs = rawParagraphs
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty && p.length > 3)
        .toList();

    if (paragraphs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No text on this page to narrate.')),
      );
      return;
    }

    final validIndex = (startIndex >= 0 && startIndex < paragraphs.length) ? startIndex : 0;

    SdaVoiceNarrationService.instance.speakQueue(
      segments: paragraphs,
      title: '${widget.book.title}: $chapterTitle',
      startIndex: validIndex,
      onIndexChanged: (idx) {
        if (mounted) setState(() => _speakingParagraphIndex = idx);
      },
      onComplete: () {
        if (mounted) setState(() => _speakingParagraphIndex = -1);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _allChapters = SopChaptersRepository.getChaptersForBook(widget.book.id, widget.book.title);
    _restoreReadingProgress();
  }

  @override
  void dispose() {
    SdaVoiceNarrationService.instance.stop();
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
        final savedFontSize = box.get('sop_font_size');
        if (savedFontSize is double) _fontSize = savedFontSize;
        final savedFontFamily = box.get('sop_font_family');
        if (savedFontFamily is String) _fontFamily = savedFontFamily;
        final savedTheme = box.get('sop_reader_theme');
        if (savedTheme is String) {
          _readerTheme = ReaderTheme.values.firstWhere(
            (e) => e.name == savedTheme,
            orElse: () => ReaderTheme.light,
          );
        }
        final savedViewMode = box.get('sop_view_mode');
        if (savedViewMode is String) {
          _viewMode = ReaderViewMode.values.firstWhere(
            (e) => e.name == savedViewMode,
            orElse: () => ReaderViewMode.paginated,
          );
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
        box.put('sop_font_size', _fontSize);
        box.put('sop_font_family', _fontFamily);
        box.put('sop_reader_theme', _readerTheme.name);
        box.put('sop_view_mode', _viewMode.name);
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

  void _showReadingPreferences() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final tts = SdaVoiceNarrationService.instance;
            final isMale = tts.gender == SdaVoiceGender.male;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Spirit of Prophecy & Voice Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 🎙️ Voice Selection (Male vs Female)
                    const Text('Voice Narration Gender', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              tts.setVoiceGender(SdaVoiceGender.male);
                              setSheetState(() {});
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isMale ? AppTheme.primaryBlue : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isMale ? AppTheme.sacredGold : Colors.grey.shade300,
                                  width: isMale ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.man, color: isMale ? AppTheme.sacredGold : Colors.black87),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Male Voice',
                                    style: TextStyle(
                                      color: isMale ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              tts.setVoiceGender(SdaVoiceGender.female);
                              setSheetState(() {});
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: !isMale ? AppTheme.primaryBlue : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: !isMale ? AppTheme.sacredGold : Colors.grey.shade300,
                                  width: !isMale ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.woman, color: !isMale ? AppTheme.sacredGold : Colors.black87),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Female Voice',
                                    style: TextStyle(
                                      color: !isMale ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Speaking Pace
                    const Text('Speaking Pace', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPaceChoice(0.35, '0.8x Solemn', tts.speechRate, (r) {
                          tts.setSpeechRate(r);
                          setSheetState(() {});
                        }),
                        const SizedBox(width: 6),
                        _buildPaceChoice(0.44, '1.0x Reverent', tts.speechRate, (r) {
                          tts.setSpeechRate(r);
                          setSheetState(() {});
                        }),
                        const SizedBox(width: 6),
                        _buildPaceChoice(0.52, '1.2x Normal', tts.speechRate, (r) {
                          tts.setSpeechRate(r);
                          setSheetState(() {});
                        }),
                        const SizedBox(width: 6),
                        _buildPaceChoice(0.60, '1.4x Fast', tts.speechRate, (r) {
                          tts.setSpeechRate(r);
                          setSheetState(() {});
                        }),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Reading Theme
                    const Text('Theme Mode', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildThemeButton('Light', ReaderTheme.light, Colors.white, Colors.black87, setSheetState),
                        const SizedBox(width: 8),
                        _buildThemeButton('Sepia', ReaderTheme.sepia, const Color(0xFFFBF0D9), const Color(0xFF3E2723), setSheetState),
                        const SizedBox(width: 8),
                        _buildThemeButton('Cream', ReaderTheme.cream, const Color(0xFFF7F4EA), const Color(0xFF2D3748), setSheetState),
                        const SizedBox(width: 8),
                        _buildThemeButton('Night', ReaderTheme.night, const Color(0xFF1E1E1E), Colors.white, setSheetState),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Font Size
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Text Size', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text('${_fontSize.toInt()} pt', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _fontSize > 12
                              ? () {
                                  setState(() => _fontSize -= 1.5);
                                  setSheetState(() {});
                                  _saveReadingProgress();
                                }
                              : null,
                        ),
                        Expanded(
                          child: Slider(
                            value: _fontSize,
                            min: 12.0,
                            max: 28.0,
                            divisions: 8,
                            activeColor: AppTheme.primaryBlue,
                            onChanged: (val) {
                              setState(() => _fontSize = val);
                              setSheetState(() {});
                              _saveReadingProgress();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _fontSize < 28
                              ? () {
                                  setState(() => _fontSize += 1.5);
                                  setSheetState(() {});
                                  _saveReadingProgress();
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Reading Mode: Paginated vs Continuous
                    const Text('Page Transition Mode', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('📖 Page Flip (Swipe ↔)')),
                            selected: _viewMode == ReaderViewMode.paginated,
                            selectedColor: AppTheme.primaryBlue,
                            labelStyle: TextStyle(
                              color: _viewMode == ReaderViewMode.paginated ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            onSelected: (sel) {
                              if (sel) {
                                setState(() => _viewMode = ReaderViewMode.paginated);
                                setSheetState(() {});
                                _saveReadingProgress();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('📜 Continuous Scroll')),
                            selected: _viewMode == ReaderViewMode.continuous,
                            selectedColor: AppTheme.primaryBlue,
                            labelStyle: TextStyle(
                              color: _viewMode == ReaderViewMode.continuous ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            onSelected: (sel) {
                              if (sel) {
                                setState(() => _viewMode = ReaderViewMode.continuous);
                                setSheetState(() {});
                                _saveReadingProgress();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeButton(
    String label,
    ReaderTheme theme,
    Color bg,
    Color text,
    void Function(void Function()) setSheetState,
  ) {
    final isSelected = _readerTheme == theme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() => _readerTheme = theme);
          setSheetState(() {});
          _saveReadingProgress();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.sacredGold : Colors.grey.shade400,
              width: isSelected ? 2.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaceChoice(double rate, String label, double currentRate, Function(double) onSelected) {
    final isSelected = (currentRate - rate).abs() < 0.04;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onSelected(rate),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.sacredGold : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
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

    final bgColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final cardColor = _getCardColor();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.book.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Ch. ${_selectedChapterIndex + 1}/$totalChapters • Pg. ${_currentPageIndex + 1}/$totalPagesInChapter',
              style: const TextStyle(fontSize: 10.5, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Audio Read-Aloud Toggle (Godly Voice Version)
          AnimatedBuilder(
            animation: SdaVoiceNarrationService.instance,
            builder: (context, _) {
              final isPlaying = SdaVoiceNarrationService.instance.isPlaying;
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                tooltip: isPlaying ? 'Voice Narration Active' : 'Listen to Page (Godly Voice)',
                icon: Icon(
                  isPlaying ? Icons.record_voice_over : Icons.headphones,
                  color: isPlaying ? AppTheme.sacredGold : Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  if (isPlaying) {
                    SdaVoiceNarrationService.instance.pause();
                  } else if (SdaVoiceNarrationService.instance.isPaused) {
                    SdaVoiceNarrationService.instance.resume();
                  } else {
                    _startSopVoiceNarration();
                  }
                },
              );
            },
          ),
          // Bookmark Page
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            tooltip: isBookmarked ? 'Remove Bookmark' : 'Bookmark Page',
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppTheme.sacredGold : Colors.white,
              size: 20,
            ),
            onPressed: () => _toggleBookmark(_selectedChapterIndex, _currentPageIndex),
          ),
          // View Bookmarks
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            tooltip: 'View Bookmarks',
            icon: const Icon(Icons.collections_bookmark_outlined, size: 19),
            onPressed: _showBookmarksSheet,
          ),
          // Read Online on EGW Writings
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            tooltip: 'Read Online (EGW Writings)',
            icon: const Icon(Icons.public, size: 19),
            onPressed: _openOnlineReader,
          ),
          // Reading Customization & Voice
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            tooltip: 'Reading Customization & Voice',
            icon: const Icon(Icons.format_size, size: 20),
            onPressed: _showReadingPreferences,
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
      // Main Body: Paginated View or Continuous View with Top Status Bar
      body: Column(
        children: [
          // Top Status Bar: Chapter & Page info with swipe prompt
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.04),
              border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 13, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Spirit of Prophecy • Offline Ready',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
                Flexible(
                  child: Text(
                    'Ch. ${_selectedChapterIndex + 1}/$totalChapters • Pg. ${_currentPageIndex + 1}/$totalPagesInChapter (Swipe ↔)',
                    style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _viewMode == ReaderViewMode.paginated
                ? _buildPaginatedView(chapter, pages, title, subtitle, scripture, totalPagesInChapter, textColor, cardColor)
                : _buildContinuousView(chapter, pages, title, subtitle, scripture, totalPagesInChapter, textColor, cardColor),
          ),
        ],
      ),
      // Bottom Bar with Voice Audio Controller & Page Navigation
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SdaVoiceAudioPlayerBar(),
          _buildBottomPageBar(totalPagesInChapter, totalChapters, textColor, cardColor),
        ],
      ),
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
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification) {
          if (notification.overscroll > 15 &&
              _currentPageIndex == totalPages - 1 &&
              _selectedChapterIndex < _allChapters.length - 1) {
            _goToChapter(_selectedChapterIndex + 1, pageIndex: 0);
            return true;
          } else if (notification.overscroll < -15 &&
              _currentPageIndex == 0 &&
              _selectedChapterIndex > 0) {
            final prevChapter = _allChapters[_selectedChapterIndex - 1];
            final prevPages = SopChaptersRepository.getPagesForChapter(prevChapter);
            _goToChapter(_selectedChapterIndex - 1, pageIndex: prevPages.isNotEmpty ? prevPages.length - 1 : 0);
            return true;
          }
        }
        return false;
      },
      child: PageView.builder(
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
              _buildParagraphsView(pageText),

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
    ),
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
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -250 && _selectedChapterIndex < _allChapters.length - 1) {
            // Swipe right-to-left -> Next Chapter
            _goToChapter(_selectedChapterIndex + 1);
          } else if (details.primaryVelocity! > 250 && _selectedChapterIndex > 0) {
            // Swipe left-to-right -> Previous Chapter
            _goToChapter(_selectedChapterIndex - 1);
          }
        }
      },
      child: SingleChildScrollView(
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
                  _buildParagraphsView(text),
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
      ),
    );
  }

  Widget _buildParagraphsView(String text) {
    final rawParagraphs = text.split(RegExp(r'\n+'));
    final paragraphs = rawParagraphs
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) {
      return SelectableText(text, style: _getPageTextStyle());
    }

    final isTtsPlaying = SdaVoiceNarrationService.instance.isPlaying;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(paragraphs.length, (idx) {
        final p = paragraphs[idx];
        final isSpeaking = _speakingParagraphIndex == idx && isTtsPlaying;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 14),
          padding: EdgeInsets.symmetric(
            horizontal: isSpeaking ? 12 : 0,
            vertical: isSpeaking ? 8 : 0,
          ),
          decoration: BoxDecoration(
            color: isSpeaking
                ? AppTheme.sacredGold.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSpeaking
                ? const Border(left: BorderSide(color: AppTheme.sacredGold, width: 3.5))
                : null,
          ),
          child: InkWell(
            onTap: () => _startSopVoiceNarration(idx),
            child: SelectableText(
              p,
              style: _getPageTextStyle().copyWith(
                fontWeight: isSpeaking ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }),
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
