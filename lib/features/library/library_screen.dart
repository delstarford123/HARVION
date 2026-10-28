import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import 'book_model.dart';
import 'pdf_detail_screen.dart';
import 'kjv_bible_reader_screen.dart';
import 'services/book_cache_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static final List<Book> _curatedOpenSourceBooks = [
    Book(
      id: 'sop_steps_to_christ',
      title: 'Steps to Christ',
      author: 'Ellen G. White',
      category: 'Spirit of Prophecy',
      description: 'The path to finding true peace, forgiveness, and salvation in Jesus Christ.',
      pdfUrl: 'https://m.egwwritings.org/en/book/108/toc',
      coverImageUrl: 'assets/images/default_cover.png',
      publishedDate: DateTime(1892),
      price: 0,
    ),
    Book(
      id: 'sop_great_controversy',
      title: 'The Great Controversy',
      author: 'Ellen G. White',
      category: 'Spirit of Prophecy',
      description: 'The monumental history of the conflict between Christ and Satan through the ages.',
      pdfUrl: 'https://m.egwwritings.org/en/book/132/toc',
      coverImageUrl: 'assets/images/default_cover.png',
      publishedDate: DateTime(1911),
      price: 0,
    ),
    Book(
      id: 'sop_desire_of_ages',
      title: 'The Desire of Ages',
      author: 'Ellen G. White',
      category: 'Spirit of Prophecy',
      description: 'The life and earthly ministry of Jesus Christ, Saviour of the world.',
      pdfUrl: 'https://m.egwwritings.org/en/book/130/toc',
      coverImageUrl: 'assets/images/default_cover.png',
      publishedDate: DateTime(1898),
      price: 0,
    ),
    Book(
      id: 'sop_ministry_of_healing',
      title: 'The Ministry of Healing',
      author: 'Ellen G. White',
      category: 'Health & Temperance',
      description: 'Principles of healthful living, natural remedies, and spiritual health ministry.',
      pdfUrl: 'https://m.egwwritings.org/en/book/135/toc',
      coverImageUrl: 'assets/images/default_cover.png',
      publishedDate: DateTime(1905),
      price: 0,
    ),
    Book(
      id: 'classic_pilgrims_progress',
      title: 'Pilgrim\'s Progress',
      author: 'John Bunyan',
      category: 'Christian Living & Family',
      description: 'The timeless allegory of Christian\'s journey from the City of Destruction to the Celestial City.',
      pdfUrl: 'https://www.gutenberg.org/ebooks/131',
      coverImageUrl: 'assets/images/default_cover.png',
      publishedDate: DateTime(1678),
      price: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Automatically preload and cache SOP books in background
    BookCacheService().preloadCoreSopBooks(_curatedOpenSourceBooks);
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
        body: StreamBuilder<QuerySnapshot>(
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
                final categoryBooks = allBooks.where((b) => b.category == category).toList();

                if (categoryBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No books available in $category yet.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: categoryBooks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildBookCard(context, categoryBooks[index]);
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    final cover = book.coverImageUrl ?? '';
    final hasCover = cover.isNotEmpty;

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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 70,
                    height: 100,
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${book.author}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (book.isPremium)
                            Text(
                              'Ksh ${book.price.toInt()}',
                              style: const TextStyle(
                                color: AppTheme.sacredGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            )
                          else
                            const Text(
                              'FREE ACCESS',
                              style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.share, size: 18, color: AppTheme.primaryBlue),
                            onPressed: () {
                              Share.share(book.generateShareText());
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
