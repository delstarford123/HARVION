import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import 'book_model.dart';
import 'data/sop_books_catalog.dart';
import 'pdf_detail_screen.dart';
import 'kjv_bible_reader_screen.dart';
import 'services/book_cache_service.dart';
import 'services/online_reader_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // Master list of curated open-source Spirit of Prophecy works (all 50) + Christian classics
  static final List<Book> _curatedOpenSourceBooks = [
    ...SopBooksCatalog.allSopBooks,
    Book(
      id: 'classic_pilgrims_progress',
      title: 'Pilgrim\'s Progress',
      author: 'John Bunyan',
      category: 'Christian Living & Family',
      series: 'Christian Classics',
      description: 'The timeless allegory of Christian\'s journey from the City of Destruction to the Celestial City.',
      pdfUrl: 'https://www.gutenberg.org/ebooks/131',
      onlineUrl: 'https://www.gutenberg.org/ebooks/131',
      coverImageUrl: 'assets/images/default_cover.png',
      publishedDate: DateTime(1678),
      price: 0,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSeries = 'All Series';

  @override
  void initState() {
    super.initState();
    // Preload top core SOP titles in the background
    BookCacheService().preloadCoreSopBooks(_curatedOpenSourceBooks.take(5).toList());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = [
      ...AppConstants.libraryCategories,
      'Farming Guides',
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text(
            'Library & SOP Books',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.sacredGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.auto_stories, size: 16),
              label: const Text('KJV BIBLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KjvBibleReaderScreen()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppTheme.sacredGold,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: tabs.map((category) => Tab(text: category)).toList(),
          ),
        ),
        body: Column(
          children: [
            // Search Bar & Filter Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search 50+ SOP books, topics, authors...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
            ),

            // Main Content TabView
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(AppConstants.colFarmingGuides)
                    .orderBy('publishedDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  final List<Book> firestoreBooks = snapshot.hasData
                      ? snapshot.data!.docs
                          .map((doc) => Book.fromJson(doc.data() as Map<String, dynamic>, doc.id))
                          .toList()
                      : [];

                  final allBooks = [...firestoreBooks];
                  for (final cb in _curatedOpenSourceBooks) {
                    if (!allBooks.any((b) => b.id == cb.id || b.title.toLowerCase() == cb.title.toLowerCase())) {
                      allBooks.add(cb);
                    }
                  }

                  return TabBarView(
                    children: tabs.map((category) {
                      List<Book> categoryBooks;

                      if (category == 'Spirit of Prophecy') {
                        // Spirit of Prophecy tab includes all 50 EGW books
                        categoryBooks = allBooks.where((b) {
                          return b.author.toLowerCase().contains('white') ||
                              b.category == 'Spirit of Prophecy';
                        }).toList();

                        // Apply Series Sub-filter
                        if (_selectedSeries != 'All Series') {
                          categoryBooks = categoryBooks.where((b) => b.series == _selectedSeries).toList();
                        }
                      } else {
                        // Other tabs show books tagged with that category or whose topics match
                        categoryBooks = allBooks.where((b) {
                          if (b.category == category) return true;
                          // Secondary cross-categorization for relevant EGW books
                          if (category == 'Health & Temperance' && (b.series == 'Health & Temperance' || b.id.contains('healing') || b.id.contains('diet'))) return true;
                          if (category == 'Christian Living & Family' && (b.series == 'Family Life, Youth & Home' || b.series == 'Christian Living & Salvation')) return true;
                          if (category == 'Evangelism & Prophecy' && (b.series == 'Church Administration & Workers' || b.series == 'Prophecy & Devotionals' || b.id.contains('evangelism'))) return true;
                          if (category == 'Children & Youth' && (b.id.contains('child') || b.id.contains('young'))) return true;
                          return false;
                        }).toList();
                      }

                      // Apply search filter
                      if (_searchQuery.isNotEmpty) {
                        categoryBooks = categoryBooks.where((b) {
                          return b.title.toLowerCase().contains(_searchQuery) ||
                              b.description.toLowerCase().contains(_searchQuery) ||
                              b.author.toLowerCase().contains(_searchQuery) ||
                              (b.series?.toLowerCase().contains(_searchQuery) ?? false);
                        }).toList();
                      }

                      return Column(
                        children: [
                          // Series Filter Chips (Visible for Spirit of Prophecy tab)
                          if (category == 'Spirit of Prophecy')
                            Container(
                              height: 44,
                              color: Colors.white,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                itemCount: SopBooksCatalog.seriesList.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, idx) {
                                  final s = SopBooksCatalog.seriesList[idx];
                                  final isSel = _selectedSeries == s;
                                  return ChoiceChip(
                                    label: Text(
                                      s,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                        color: isSel ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    selected: isSel,
                                    selectedColor: AppTheme.primaryBlue,
                                    backgroundColor: Colors.grey.shade100,
                                    onSelected: (val) {
                                      setState(() {
                                        _selectedSeries = s;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),

                          // Books List
                          Expanded(
                            child: categoryBooks.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.library_books, size: 64, color: Colors.grey.shade300),
                                        const SizedBox(height: 16),
                                        Text(
                                          _searchQuery.isNotEmpty
                                              ? 'No books matching "$_searchQuery".'
                                              : 'No books in $category yet.',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(16.0),
                                    itemCount: categoryBooks.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                                    itemBuilder: (context, index) {
                                      return _buildBookCard(context, categoryBooks[index]);
                                    },
                                  ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    final cover = book.coverImageUrl ?? '';
    final hasCover = cover.isNotEmpty;
    final series = book.series;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfDetailScreen(
                  pdfId: book.id,
                  title: book.title,
                  description: book.description,
                  price: book.price.toInt(),
                  pdfUrl: book.pdfUrl,
                  bookObject: book,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover or Icon
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 70,
                        height: 98,
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        child: hasCover && cover.startsWith('http')
                            ? Image.network(
                                cover,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.menu_book, color: AppTheme.primaryBlue, size: 36),
                              )
                            : hasCover
                                ? Image.asset(
                                    cover,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.menu_book, color: AppTheme.primaryBlue, size: 36),
                                  )
                                : const Icon(Icons.menu_book, color: AppTheme.primaryBlue, size: 36),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Book Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  book.category.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              if (series != null && series.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    series,
                                    style: const TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            book.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'By ${book.author}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Action Buttons Row (Read Online + Offline / Details + Share)
                Row(
                  children: [
                    // Quick Read Online Button (EGW Writings)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(60, 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.public, color: AppTheme.sacredGold, size: 14),
                      label: const Text(
                        'Read Online',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        OnlineReaderService.openOnlineBook(
                          context,
                          book.effectiveOnlineUrl,
                          title: book.title,
                        );
                      },
                    ),
                    const SizedBox(width: 8),

                    // Quick Chapter Reader
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        side: const BorderSide(color: AppTheme.primaryGreen, width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        minimumSize: const Size(60, 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.auto_stories, size: 14),
                      label: const Text(
                        'Chapters',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfDetailScreen(
                              pdfId: book.id,
                              title: book.title,
                              description: book.description,
                              price: book.price.toInt(),
                              pdfUrl: book.pdfUrl,
                              bookObject: book,
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),

                    // Share Button
                    IconButton(
                      icon: const Icon(Icons.share, size: 18, color: AppTheme.primaryBlue),
                      tooltip: 'Share Book',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Share.share(book.generateShareText());
                      },
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
}
