import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';

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
  double _fontSize = 17.0;
  bool _isDarkReadingMode = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _verses = [];

  static const List<String> oldTestament = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
    'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
    '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra',
    'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
    'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah', 'Lamentations',
    'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
    'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk',
    'Zephaniah', 'Haggai', 'Zechariah', 'Malachi'
  ];

  static const List<String> newTestament = [
    'Matthew', 'Mark', 'Luke', 'John', 'Acts',
    'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians',
    'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy',
    '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James',
    '1 Peter', '2 Peter', '1 John', '2 John', '3 John',
    'Jude', 'Revelation'
  ];

  @override
  void initState() {
    super.initState();
    _selectedBook = widget.initialBook;
    _selectedChapter = widget.initialChapter;
    _loadChapterContent();
  }

  Future<void> _loadChapterContent() async {
    setState(() => _isLoading = true);

    // Try fetching from public domain Bible API
    try {
      final formattedBook = _selectedBook.replaceAll(' ', '+');
      final url = Uri.parse('https://bible-api.com/$formattedBook+$_selectedChapter?translation=kjv');
      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['verses'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _verses = list.map((v) => {
              'verse': v['verse'] as int? ?? 0,
              'text': v['text'] as String? ?? '',
            }).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {
      // Fallback to offline curated scriptures
    }

    // Curated offline fallback for key prophetic and gospel passages
    final fallback = _getOfflineFallback(_selectedBook, _selectedChapter);
    if (mounted) {
      setState(() {
        _verses = fallback;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getOfflineFallback(String book, int chapter) {
    if (book == 'Revelation' && chapter == 14) {
      return [
        {'verse': 6, 'text': 'And I saw another angel fly in the midst of heaven, having the everlasting gospel to preach unto them that dwell on the earth, and to every nation, and kindred, and tongue, and people,'},
        {'verse': 7, 'text': 'Saying with a loud voice, Fear God, and give glory to him; for the hour of his judgment is come: and worship him that made heaven, and earth, and the sea, and the fountains of waters.'},
        {'verse': 8, 'text': 'And there followed another angel, saying, Babylon is fallen, is fallen, that great city, because she made all nations drink of the wine of the wrath of her fornication.'},
        {'verse': 9, 'text': 'And the third angel followed them, saying with a loud voice, If any man worship the beast and his image, and receive his mark in his forehead, or in his hand,'},
        {'verse': 10, 'text': 'The same shall drink of the wine of the wrath of God, which is poured out without mixture into the cup of his indignation; and he shall be tormented with fire and brimstone in the presence of the holy angels, and in the presence of the Lamb:'},
        {'verse': 11, 'text': 'And the smoke of their torment ascendeth up for ever and ever: and they have no rest day nor night, who worship the beast and his image, and whosoever receiveth the mark of his name.'},
        {'verse': 12, 'text': 'Here is the patience of the saints: here are they that keep the commandments of God, and the faith of Jesus.'},
      ];
    } else if (book == 'Exodus' && chapter == 20) {
      return [
        {'verse': 1, 'text': 'And God spake all these words, saying,'},
        {'verse': 2, 'text': 'I am the LORD thy God, which have brought thee out of the land of Egypt, out of the house of bondage.'},
        {'verse': 3, 'text': 'Thou shalt have no other gods before me.'},
        {'verse': 8, 'text': 'Remember the sabbath day, to keep it holy.'},
        {'verse': 9, 'text': 'Six days shalt thou labour, and do all thy work:'},
        {'verse': 10, 'text': 'But the seventh day is the sabbath of the LORD thy God: in it thou shalt not do any work, thou, nor thy son, nor thy daughter, thy manservant, nor thy maidservant, nor thy cattle, nor thy stranger that is within thy gates:'},
        {'verse': 11, 'text': 'For in six days the LORD made heaven and earth, the sea, and all that in them is, and rested the seventh day: wherefore the LORD blessed the sabbath day, and hallowed it.'},
      ];
    } else if (book == 'Psalms' && chapter == 23) {
      return [
        {'verse': 1, 'text': 'The LORD is my shepherd; I shall not want.'},
        {'verse': 2, 'text': 'He maketh me to lie down in green pastures: he leadeth me beside the still waters.'},
        {'verse': 3, 'text': 'He restoreth my soul: he leadeth me in the paths of righteousness for his name\'s sake.'},
        {'verse': 4, 'text': 'Yea, though I walk through the valley of the shadow of death, I will fear no evil: for thou art with me; thy rod and thy staff they comfort me.'},
        {'verse': 5, 'text': 'Thou preparest a table before me in the presence of mine enemies: thou anointest my head with oil; my cup runneth over.'},
        {'verse': 6, 'text': 'Surely goodness and mercy shall follow me all the days of my life: and I will dwell in the house of the LORD for ever.'},
      ];
    }

    return [
      {'verse': 1, 'text': 'In the beginning God created the heaven and the earth.'},
      {'verse': 2, 'text': 'Thy word is a lamp unto my feet, and a light unto my path. (Psalm 119:105)'},
      {'verse': 3, 'text': 'Connect to network to download all verses in this chapter, or read in offline mode.'},
    ];
  }

  void _showBookPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: SizedBox(
            height: 480,
            child: Column(
              children: [
                const TabBar(
                  indicatorColor: AppTheme.sacredGold,
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Old Testament (39)'),
                    Tab(text: 'New Testament (27)'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildBookGrid(oldTestament),
                      _buildBookGrid(newTestament),
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
        childAspectRatio: 2.4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: books.length,
      itemBuilder: (context, i) {
        final b = books[i];
        final isSelected = b == _selectedBook;
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
              border: Border.all(color: isSelected ? AppTheme.sacredGold : Colors.grey.shade300),
            ),
            child: Text(
              b,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  void _showChapterPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Chapter - $_selectedBook',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 50,
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
                          color: isSel ? AppTheme.sacredGold : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$ch',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.black : Colors.black87,
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

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkReadingMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFDF8);
    final textColor = _isDarkReadingMode ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    final verseNumColor = _isDarkReadingMode ? AppTheme.sacredGold : AppTheme.primaryBlue;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('$_selectedBook $_selectedChapter (KJV)', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Choose Book',
            icon: const Icon(Icons.menu_book),
            onPressed: _showBookPicker,
          ),
          IconButton(
            tooltip: 'Choose Chapter',
            icon: const Icon(Icons.numbers),
            onPressed: _showChapterPicker,
          ),
          IconButton(
            tooltip: _isDarkReadingMode ? 'Light Reading Mode' : 'Night Reading Mode',
            icon: Icon(_isDarkReadingMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _isDarkReadingMode = !_isDarkReadingMode),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Font Size',
            onSelected: (val) {
              setState(() {
                if (val == 'increase' && _fontSize < 28) _fontSize += 2;
                if (val == 'decrease' && _fontSize > 13) _fontSize -= 2;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'increase', child: Text('A+ Enlarge Font')),
              const PopupMenuItem(value: 'decrease', child: Text('A- Reduce Font')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.sacredGold))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Chapter Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _selectedBook.toUpperCase(),
                          style: TextStyle(
                            fontSize: 13,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                            color: verseNumColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chapter $_selectedChapter',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 60,
                          height: 2,
                          color: AppTheme.sacredGold,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Verses
                  ..._verses.map((v) {
                    final vNum = v['verse'];
                    final text = v['text'].toString().trim();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onLongPress: () {
                          Share.share(
                            '📖 "$text"\n— $_selectedBook $_selectedChapter:$vNum (KJV)\nHarvion SDA Ministry',
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                '$vNum',
                                style: TextStyle(
                                  fontSize: _fontSize * 0.75,
                                  fontWeight: FontWeight.bold,
                                  color: verseNumColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontSize: _fontSize,
                                  height: 1.65,
                                  fontFamily: 'serif',
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 30),

                  // Bottom Chapter Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_selectedChapter > 1)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.chevron_left),
                          label: Text('Chapter ${_selectedChapter - 1}'),
                          onPressed: () {
                            setState(() => _selectedChapter--);
                            _loadChapterContent();
                          },
                        )
                      else
                        const SizedBox.shrink(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.chevron_right),
                        label: Text('Chapter ${_selectedChapter + 1}'),
                        onPressed: () {
                          setState(() => _selectedChapter++);
                          _loadChapterContent();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
