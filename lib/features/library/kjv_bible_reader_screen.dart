import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'data/kjv_bible_service.dart';

enum BibleTheme { light, night, sepia, cream }

class KjvBibleReaderScreen extends StatefulWidget {
  final String initialBook;
  final int initialChapter;

  const KjvBibleReaderScreen({
    super.key,
    this.initialBook = 'Revelation',
    this.initialChapter = 14,
  });

  @override
  State<KjvBibleReaderScreen> createState() => _KjvBibleReaderScreenState();
}

class _KjvBibleReaderScreenState extends State<KjvBibleReaderScreen> {
  late String _selectedBook;
  late int _selectedChapter;
  double _fontSize = 17.5;
  String _fontFamily = 'Serif';
  BibleTheme _theme = BibleTheme.light;
  bool _isLoading = true;
  List<Map<String, dynamic>> _verses = [];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedBook = widget.initialBook;
    _selectedChapter = widget.initialChapter;
    _initializeBible();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeBible() async {
    setState(() => _isLoading = true);
    await KjvBibleService.instance.ensureInitialized();
    _loadChapterContent();
  }

  void _loadChapterContent() {
    final verses = KjvBibleService.instance.getVerses(_selectedBook, _selectedChapter);
    if (mounted) {
      setState(() {
        _verses = verses;
        _isLoading = false;
      });
      // Scroll to top on chapter change
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _nextChapter() {
    final totalChapters = KjvBibleService.instance.getChapterCount(_selectedBook);
    if (_selectedChapter < totalChapters) {
      setState(() => _selectedChapter++);
      _loadChapterContent();
    } else {
      // Move to next book if available
      final allBooks = [
        ...KjvBibleService.oldTestament,
        ...KjvBibleService.newTestament
      ];
      final currentIndex = allBooks.indexOf(_selectedBook);
      if (currentIndex != -1 && currentIndex + 1 < allBooks.length) {
        setState(() {
          _selectedBook = allBooks[currentIndex + 1];
          _selectedChapter = 1;
        });
        _loadChapterContent();
      }
    }
  }

  void _previousChapter() {
    if (_selectedChapter > 1) {
      setState(() => _selectedChapter--);
      _loadChapterContent();
    } else {
      // Move to previous book if available
      final allBooks = [
        ...KjvBibleService.oldTestament,
        ...KjvBibleService.newTestament
      ];
      final currentIndex = allBooks.indexOf(_selectedBook);
      if (currentIndex > 0) {
        final prevBook = allBooks[currentIndex - 1];
        final prevBookTotalChapters = KjvBibleService.instance.getChapterCount(prevBook);
        setState(() {
          _selectedBook = prevBook;
          _selectedChapter = prevBookTotalChapters;
        });
        _loadChapterContent();
      }
    }
  }

  Color _getBackgroundColor() {
    switch (_theme) {
      case BibleTheme.light:
        return const Color(0xFFFFFDF8);
      case BibleTheme.night:
        return const Color(0xFF121212);
      case BibleTheme.sepia:
        return const Color(0xFFFBF0D9);
      case BibleTheme.cream:
        return const Color(0xFFF7F4EA);
    }
  }

  Color _getTextColor() {
    switch (_theme) {
      case BibleTheme.light:
        return const Color(0xFF212121);
      case BibleTheme.night:
        return const Color(0xFFE0E0E0);
      case BibleTheme.sepia:
        return const Color(0xFF2D2418);
      case BibleTheme.cream:
        return const Color(0xFF2C2C2C);
    }
  }

  Color _getVerseNumberColor() {
    switch (_theme) {
      case BibleTheme.light:
        return AppTheme.primaryBlue;
      case BibleTheme.night:
        return AppTheme.sacredGold;
      case BibleTheme.sepia:
        return const Color(0xFF8C5D1E);
      case BibleTheme.cream:
        return const Color(0xFF5D4037);
    }
  }

  void _showBookPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: SizedBox(
            height: 520,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Bible Book (KJV)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
                const TabBar(
                  indicatorColor: AppTheme.sacredGold,
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: 'Old Testament (39)'),
                    Tab(text: 'New Testament (27)'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildBookGrid(KjvBibleService.oldTestament),
                      _buildBookGrid(KjvBibleService.newTestament),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookGrid(List<String> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: books.length,
      itemBuilder: (context, i) {
        final b = books[i];
        final isSelected = b == _selectedBook;
        final chapters = KjvBibleService.instance.getChapterCount(b);
        return InkWell(
          onTap: () {
            Navigator.pop(context);
            setState(() {
              _selectedBook = b;
              _selectedChapter = 1;
            });
            _loadChapterContent();
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppTheme.sacredGold : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  b,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$chapters ch',
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? AppTheme.sacredGold : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChapterPicker() {
    final totalChapters = KjvBibleService.instance.getChapterCount(_selectedBook);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 420,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedBook — Select Chapter',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                  ),
                  Text(
                    '$totalChapters Total Chapters',
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: totalChapters,
                  itemBuilder: (context, i) {
                    final ch = i + 1;
                    final isSel = ch == _selectedChapter;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _selectedChapter = ch);
                        _loadChapterContent();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.primaryBlue : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel ? AppTheme.sacredGold : Colors.grey.shade300,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          '$ch',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSearchDialog() {
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
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SizedBox(
                height: 550,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.primaryBlue),
                        const SizedBox(width: 8),
                        const Text(
                          'Search Scriptures (KJV)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search word or phrase (e.g. Sabbath, Faith, Seal)...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            final q = _searchController.text.trim();
                            if (q.isNotEmpty) {
                              setSheetState(() => _isSearching = true);
                              final res = KjvBibleService.instance.searchVerses(q);
                              setSheetState(() {
                                _searchResults = res;
                                _isSearching = false;
                              });
                            }
                          },
                        ),
                      ),
                      onSubmitted: (q) {
                        if (q.trim().isNotEmpty) {
                          setSheetState(() => _isSearching = true);
                          final res = KjvBibleService.instance.searchVerses(q);
                          setSheetState(() {
                            _searchResults = res;
                            _isSearching = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_isSearching)
                      const Expanded(child: Center(child: CircularProgressIndicator()))
                    else if (_searchResults.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text('Type a keyword to search all 66 books of the Bible.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final item = _searchResults[i];
                            return ListTile(
                              title: Text(
                                '${item['book']} ${item['chapter']}:${item['verse']}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                              ),
                              subtitle: Text(
                                item['text'].toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _selectedBook = item['book'] as String;
                                  _selectedChapter = item['chapter'] as int;
                                });
                                _loadChapterContent();
                              },
                            );
                          },
                        ),
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

  void _showReadingPreferences() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reading Customization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text('Theme Mode', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildThemeTile('Light', BibleTheme.light, const Color(0xFFFFFDF8), Colors.black, setSheetState),
                      _buildThemeTile('Night', BibleTheme.night, const Color(0xFF121212), Colors.white, setSheetState),
                      _buildThemeTile('Sepia', BibleTheme.sepia, const Color(0xFFFBF0D9), const Color(0xFF2D2418), setSheetState),
                      _buildThemeTile('Cream', BibleTheme.cream, const Color(0xFFF7F4EA), const Color(0xFF2C2C2C), setSheetState),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Font Size', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (_fontSize > 13) {
                            setState(() => _fontSize -= 1.0);
                            setSheetState(() {});
                          }
                        },
                      ),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 13.0,
                          max: 28.0,
                          activeColor: AppTheme.primaryBlue,
                          onChanged: (val) {
                            setState(() => _fontSize = val);
                            setSheetState(() {});
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          if (_fontSize < 28) {
                            setState(() => _fontSize += 1.0);
                            setSheetState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeTile(String label, BibleTheme t, Color bg, Color textCol, StateSetter setSheetState) {
    final isSel = _theme == t;
    return InkWell(
      onTap: () {
        setState(() => _theme = t);
        setSheetState(() {});
      },
      child: Column(
        children: [
          Container(
            width: 55,
            height: 45,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSel ? AppTheme.sacredGold : Colors.grey.shade400, width: isSel ? 3 : 1),
            ),
            alignment: Alignment.center,
            child: Text('Aa', style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  void _shareVerse(int verseNum, String verseText) {
    final content = '$_selectedBook $_selectedChapter:$verseNum (KJV)\n\n"$verseText"\n\n— Read on HARVION SDA Ministry App';
    Share.share(content);
  }

  void _copyVerse(int verseNum, String verseText) {
    final content = '$_selectedBook $_selectedChapter:$verseNum (KJV) — "$verseText"';
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $_selectedBook $_selectedChapter:$verseNum to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final verseNumColor = _getVerseNumberColor();
    final totalChapters = KjvBibleService.instance.getChapterCount(_selectedBook);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: InkWell(
          onTap: _showBookPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_selectedBook $_selectedChapter',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Icon(Icons.arrow_drop_down, color: AppTheme.sacredGold),
            ],
          ),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Search Bible',
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            tooltip: 'Select Chapter',
            icon: const Icon(Icons.numbers),
            onPressed: _showChapterPicker,
          ),
          IconButton(
            tooltip: 'Reading Customization',
            icon: const Icon(Icons.format_size),
            onPressed: _showReadingPreferences,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Status Bar: Book info & offline indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Complete KJV Offline',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.7)),
                          ),
                        ],
                      ),
                      Text(
                        'Chapter $_selectedChapter of $totalChapters • ${_verses.length} Verses',
                        style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),

                // Verses List View
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: _verses.length,
                    itemBuilder: (context, index) {
                      final item = _verses[index];
                      final vNum = item['verse'] as int? ?? (index + 1);
                      final text = item['text'] as String? ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: InkWell(
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => Container(
                                padding: const EdgeInsets.all(16),
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.copy, color: AppTheme.primaryBlue),
                                      title: const Text('Copy Verse'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _copyVerse(vNum, text);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.share, color: AppTheme.sacredGold),
                                      title: const Text('Share Verse'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _shareVerse(vNum, text);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$vNum ',
                                  style: TextStyle(
                                    fontSize: _fontSize * 0.75,
                                    fontWeight: FontWeight.bold,
                                    color: verseNumColor,
                                    fontFamily: _fontFamily,
                                  ),
                                ),
                                TextSpan(
                                  text: text,
                                  style: TextStyle(
                                    fontSize: _fontSize,
                                    color: textColor,
                                    fontFamily: _fontFamily,
                                    height: 1.65,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Navigation Bar for Chapter prev/next
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.arrow_back_ios, size: 14),
                        label: const Text('Prev Ch', style: TextStyle(fontSize: 12)),
                        onPressed: _previousChapter,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.format_list_numbered, size: 16, color: AppTheme.primaryBlue),
                        label: Text(
                          '$_selectedBook $_selectedChapter',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                        ),
                        onPressed: _showChapterPicker,
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        label: const Text('Next Ch', style: TextStyle(fontSize: 12)),
                        icon: const Icon(Icons.arrow_forward_ios, size: 14),
                        onPressed: _nextChapter,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
