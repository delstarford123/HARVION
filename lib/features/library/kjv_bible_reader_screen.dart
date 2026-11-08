import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/services/sda_voice_narration_service.dart';
import '../../core/widgets/sda_voice_audio_player_bar.dart';
import 'data/kjv_bible_service.dart';
import 'data/bible_multilang_service.dart';

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
  int _speakingVerseIndex = -1;

  void _restoreSettings() {
    try {
      if (Hive.isBoxOpen(AppConstants.boxSavedArticles)) {
        final box = Hive.box(AppConstants.boxSavedArticles);
        final size = box.get('bible_font_size');
        if (size is double) _fontSize = size;
        final family = box.get('bible_font_family');
        if (family is String) _fontFamily = family;
        final themeName = box.get('bible_theme');
        if (themeName is String) {
          _theme = BibleTheme.values.firstWhere(
            (e) => e.name == themeName,
            orElse: () => BibleTheme.light,
          );
        }
        final trName = box.get('bible_translation');
        if (trName is String) {
          final foundTr = BibleTranslation.values.firstWhere(
            (e) => e.name == trName,
            orElse: () => BibleTranslation.kjv,
          );
          BibleMultiLangService.instance.setTranslation(foundTr);
        }
      }
    } catch (_) {}
  }

  void _saveSettings() {
    try {
      if (Hive.isBoxOpen(AppConstants.boxSavedArticles)) {
        final box = Hive.box(AppConstants.boxSavedArticles);
        box.put('bible_font_size', _fontSize);
        box.put('bible_font_family', _fontFamily);
        box.put('bible_theme', _theme.name);
        box.put('bible_translation', BibleMultiLangService.instance.currentTranslation.name);
      }
    } catch (_) {}
  }

  void _startChapterVoiceNarration([int startIndex = 0]) {
    if (_verses.isEmpty) return;
    final segments = _verses.map((v) {
      final vNum = v['verse'] as int? ?? 1;
      final text = v['text'] as String? ?? '';
      return 'Verse $vNum. $text';
    }).toList();

    final tr = BibleMultiLangService.instance.currentTranslation;
    final localizedBook = BibleMultiLangService.instance.getLocalizedBookName(_selectedBook);

    SdaVoiceNarrationService.instance.setLanguage(tr.locale);

    SdaVoiceNarrationService.instance.speakQueue(
      segments: segments,
      title: '$localizedBook $_selectedChapter (${tr.languageName})',
      startIndex: startIndex,
      onIndexChanged: (idx) {
        if (mounted) {
          setState(() => _speakingVerseIndex = idx);
          if (_scrollController.hasClients && idx > 2) {
            _scrollController.animateTo(
              (idx * 70.0).clamp(0.0, _scrollController.position.maxScrollExtent),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      },
      onComplete: () {
        if (mounted) {
          setState(() => _speakingVerseIndex = -1);
        }
      },
    );
  }

  void _listenToSpecificVerse(int index) {
    _startChapterVoiceNarration(index);
  }

  @override
  void initState() {
    super.initState();
    BibleMultiLangService.instance.init();
    _restoreSettings();
    _selectedBook = widget.initialBook;
    _selectedChapter = widget.initialChapter;
    _initializeBible();
  }

  @override
  void dispose() {
    SdaVoiceNarrationService.instance.stop();
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
    _speakingVerseIndex = -1;
    final translated = BibleMultiLangService.instance.getTranslatedVerses(_selectedBook, _selectedChapter);
    final verses = translated ?? KjvBibleService.instance.getVerses(_selectedBook, _selectedChapter);
    if (mounted) {
      setState(() {
        _verses = verses;
        _isLoading = false;
      });
      _saveSettings();
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
      final allBooks = [
        ...KjvBibleService.oldTestament,
        ...KjvBibleService.newTestament
      ];
      final currentIndex = allBooks.indexOf(_selectedBook);
      if (currentIndex > 0) {
        final prevBook = allBooks[currentIndex - 1];
        final prevBookChapters = KjvBibleService.instance.getChapterCount(prevBook);
        setState(() {
          _selectedBook = prevBook;
          _selectedChapter = prevBookChapters;
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
        return const Color(0xFF1A1A1A);
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
        return const Color(0xFF8B4513);
      case BibleTheme.cream:
        return const Color(0xFF5C4033);
    }
  }

  void _showTranslationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.language, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text('Bible Translation & Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BibleTranslation.values.map((tr) {
            final isSelected = BibleMultiLangService.instance.currentTranslation == tr;
            return ListTile(
              leading: Text(tr.flag, style: const TextStyle(fontSize: 22)),
              title: Text(tr.label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
              subtitle: Text(tr.languageName, style: const TextStyle(fontSize: 12)),
              trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen) : null,
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  BibleMultiLangService.instance.setTranslation(tr);
                });
                _saveSettings();
                _loadChapterContent();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Switched to ${tr.label} (${tr.languageName})'),
                    backgroundColor: AppTheme.primaryGreen,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBookPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                        'Select Bible Book',
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
        childAspectRatio: 1.95,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: books.length,
      itemBuilder: (context, i) {
        final b = books[i];
        final isSelected = b == _selectedBook;
        final chapters = KjvBibleService.instance.getChapterCount(b);
        final localizedName = BibleMultiLangService.instance.getLocalizedBookName(b);

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.pop(context);
            setState(() {
              _selectedBook = b;
              _selectedChapter = 1;
            });
            _loadChapterContent();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    localizedName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
    final localizedBook = BibleMultiLangService.instance.getLocalizedBookName(_selectedBook);

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
                  Expanded(
                    child: Text(
                      '$localizedBook — Select Chapter',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$totalChapters Chapters',
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: totalChapters,
                  itemBuilder: (context, i) {
                    final ch = i + 1;
                    final isCurrent = ch == _selectedChapter;
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _selectedChapter = ch);
                        _loadChapterContent();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCurrent ? AppTheme.primaryBlue : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrent ? AppTheme.sacredGold : Colors.grey.shade300,
                            width: isCurrent ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          '$ch',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? Colors.white : Colors.black87,
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
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                height: 480,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Scriptures (e.g. faith, Sabbath, peace)...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                          final res = KjvBibleService.instance.searchVerses(q.trim());
                          setSheetState(() {
                            _searchResults = res;
                            _isSearching = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_isSearching)
                      const Center(child: CircularProgressIndicator())
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
                        const Text('Reading Customization & Voice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
                                  Icon(Icons.man, color: isMale ? Colors.white : Colors.black87, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Male Minister Voice',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isMale ? Colors.white : Colors.black87,
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
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
                                  Icon(Icons.woman, color: !isMale ? Colors.white : Colors.black87, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Female Sister Voice',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: !isMale ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Speaking Pacing / Speed
                    const Text('Speaking Speed', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSpeedOption('0.8x Solemn', 0.35, tts, setSheetState),
                        _buildSpeedOption('1.0x Default', 0.44, tts, setSheetState),
                        _buildSpeedOption('1.2x Normal', 0.52, tts, setSheetState),
                        _buildSpeedOption('1.4x Fast', 0.60, tts, setSheetState),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Theme Mode
                    const Text('Theme Mode', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
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
                    const SizedBox(height: 18),

                    // Font Size Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Font Size', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text('${_fontSize.toStringAsFixed(1)} pt', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (_fontSize > 13) {
                              setState(() => _fontSize -= 1.0);
                              _saveSettings();
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
                              _saveSettings();
                              setSheetState(() {});
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            if (_fontSize < 28) {
                              setState(() => _fontSize += 1.0);
                              _saveSettings();
                              setSheetState(() {});
                            }
                          },
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

  Widget _buildSpeedOption(String label, double rate, SdaVoiceNarrationService tts, StateSetter setSheetState) {
    final isSelected = (tts.speechRate - rate).abs() < 0.04;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        tts.setSpeechRate(rate);
        setSheetState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppTheme.sacredGold : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeTile(String label, BibleTheme t, Color bg, Color textCol, StateSetter setSheetState) {
    final isSel = _theme == t;
    return InkWell(
      onTap: () {
        setState(() => _theme = t);
        _saveSettings();
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
              border: Border.all(
                color: isSel ? AppTheme.sacredGold : Colors.grey.shade300,
                width: isSel ? 2.5 : 1,
              ),
            ),
            child: Center(
              child: Text('Aa', style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  void _shareVerse(int verseNum, String verseText) {
    final localizedBook = BibleMultiLangService.instance.getLocalizedBookName(_selectedBook);
    final content = '$localizedBook $_selectedChapter:$verseNum\n\n"$verseText"\n\n— Read on HARVION SDA Ministry App';
    Share.share(content);
  }

  void _copyVerse(int verseNum, String verseText) {
    final localizedBook = BibleMultiLangService.instance.getLocalizedBookName(_selectedBook);
    final content = '$localizedBook $_selectedChapter:$verseNum — "$verseText"';
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $localizedBook $_selectedChapter:$verseNum to clipboard'),
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
    final localizedBook = BibleMultiLangService.instance.getLocalizedBookName(_selectedBook);
    final tr = BibleMultiLangService.instance.currentTranslation;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _showBookPicker,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    '$localizedBook $_selectedChapter',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_drop_down, color: AppTheme.sacredGold, size: 20),
              ],
            ),
          ),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          // Translation Selector Pill
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _showTranslationDialog,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tr.flag, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 3),
                  Text(
                    tr.languageName,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),

          // Audio Narration Button
          AnimatedBuilder(
            animation: SdaVoiceNarrationService.instance,
            builder: (context, _) {
              final isPlaying = SdaVoiceNarrationService.instance.isPlaying;
              return IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: isPlaying ? 'Voice Narration Active' : 'Listen to Chapter (Voice Version)',
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
                    _startChapterVoiceNarration(0);
                  }
                },
              );
            },
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Search Bible',
            icon: const Icon(Icons.search, size: 20),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Select Chapter',
            icon: const Icon(Icons.numbers, size: 20),
            onPressed: _showChapterPicker,
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Reading Customization & Voice',
            icon: const Icon(Icons.format_size, size: 20),
            onPressed: _showReadingPreferences,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Status Bar: Book info, translation, & swipe prompt
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
                            '${tr.label} • Offline',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Ch. $_selectedChapter of $totalChapters • ${_verses.length} Verses (Swipe ↔)',
                          style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.7)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),

                // Verses List View with Horizontal Swipe Gestures
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! < -250) {
                          // Swiped right-to-left -> Next Chapter
                          _nextChapter();
                        } else if (details.primaryVelocity! > 250) {
                          // Swiped left-to-right -> Previous Chapter
                          _previousChapter();
                        }
                      }
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: _verses.length,
                      itemBuilder: (context, index) {
                        final item = _verses[index];
                        final vNum = item['verse'] as int? ?? (index + 1);
                        final text = item['text'] as String? ?? '';
                        final isCurrentSpeaking = _speakingVerseIndex == index && SdaVoiceNarrationService.instance.isPlaying;

                        final isThreeAngelsMessage = _selectedBook.toLowerCase().contains('revelation') &&
                            _selectedChapter == 14 &&
                            vNum >= 6 &&
                            vNum <= 12;

                        final isFourthCommandment = _selectedBook.toLowerCase().contains('exodus') &&
                            _selectedChapter == 20 &&
                            vNum >= 8 &&
                            vNum <= 11;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Special Three Angels' Messages Banner
                            if (_selectedBook.toLowerCase().contains('revelation') && _selectedChapter == 14 && vNum == 6)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.sacredGold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.5)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.campaign, color: AppTheme.primaryBlue, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'THE THREE ANGELS\' MESSAGES • UJUMBE WA MALAIKA WATATU',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primaryBlue,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Special Fourth Commandment Banner
                            if (_selectedBook.toLowerCase().contains('exodus') && _selectedChapter == 20 && vNum == 8)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.sacredGold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.5)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: AppTheme.primaryBlue, size: 14),
                                    SizedBox(width: 6),
                                    Text(
                                      'THE FOURTH COMMANDMENT • THE HOLY SABBATH DAY',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.primaryBlue,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => _listenToSpecificVerse(index),
                                onLongPress: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (_) => Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Wrap(
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.record_voice_over, color: AppTheme.sacredGold),
                                            title: Text('Listen to Verse $vNum (Voice Narration)'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _listenToSpecificVerse(index);
                                            },
                                          ),
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
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(horizontal: isCurrentSpeaking ? 10 : 4, vertical: isCurrentSpeaking ? 6 : 2),
                                  decoration: BoxDecoration(
                                    color: isCurrentSpeaking
                                        ? AppTheme.sacredGold.withValues(alpha: 0.18)
                                        : (isThreeAngelsMessage || isFourthCommandment
                                            ? AppTheme.sacredGold.withValues(alpha: 0.05)
                                            : Colors.transparent),
                                    borderRadius: BorderRadius.circular(8),
                                    border: isCurrentSpeaking
                                        ? Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.6))
                                        : (isThreeAngelsMessage || isFourthCommandment
                                            ? const Border(left: BorderSide(color: AppTheme.sacredGold, width: 2.5))
                                            : null),
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '$vNum ',
                                          style: TextStyle(
                                            fontSize: _fontSize * 0.75,
                                            fontWeight: FontWeight.bold,
                                            color: isCurrentSpeaking ? AppTheme.primaryBlue : verseNumColor,
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
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // 🎙️ Voice Audio Narration Floating Bar
                const SdaVoiceAudioPlayerBar(),

                // Bottom Navigation Bar for Chapter prev/next
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        icon: const Icon(Icons.arrow_back_ios, size: 12),
                        label: const Text('Prev', style: TextStyle(fontSize: 12)),
                        onPressed: _previousChapter,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(0, 36),
                          ),
                          icon: const Icon(Icons.format_list_numbered, size: 15, color: AppTheme.primaryBlue),
                          label: Text(
                            '$localizedBook $_selectedChapter',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: _showChapterPicker,
                        ),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        label: const Text('Next', style: TextStyle(fontSize: 12)),
                        icon: const Icon(Icons.arrow_forward_ios, size: 12),
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
