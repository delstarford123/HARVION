import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import 'models/physical_book_model.dart';
import 'services/cart_service.dart';
import 'services/wishlist_service.dart';
import 'book_detail_screen.dart';
import 'cart_screen.dart';

class BookstoreScreen extends StatefulWidget {
  const BookstoreScreen({super.key});

  @override
  State<BookstoreScreen> createState() => _BookstoreScreenState();
}

class _BookstoreScreenState extends State<BookstoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _filterFormat;
  String? _filterLanguage;
  double? _maxPrice;

  final cartService = CartService();
  final wishlistService = WishlistService();

  final List<String> _categories = [
    'All Categories',
    ...AppConstants.bookstoreCategories,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<PhysicalBook> _filterBooks(List<PhysicalBook> allBooks, String category) {
    return allBooks.where((book) {
      // Must be approved
      if (!book.isApproved) return false;

      // Category match
      if (category != 'All Categories' && book.category != category) {
        return false;
      }
      // Search query match
      if (_searchQuery.isNotEmpty) {
        final titleMatch = book.title.toLowerCase().contains(_searchQuery);
        final authorMatch = book.author.toLowerCase().contains(_searchQuery);
        final descMatch = book.description.toLowerCase().contains(_searchQuery);
        if (!titleMatch && !authorMatch && !descMatch) return false;
      }
      // Format filter
      if (_filterFormat != null) {
        if (_filterFormat == 'Digital (PDF)' && !book.hasSoftCopy) return false;
        if (_filterFormat != 'Digital (PDF)' && !book.format.toLowerCase().contains(_filterFormat!.toLowerCase())) {
          return false;
        }
      }
      // Language filter
      if (_filterLanguage != null && book.language != _filterLanguage) {
        return false;
      }
      // Price filter
      if (_maxPrice != null && book.price > _maxPrice!) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String? tempFormat = _filterFormat;
        String? tempLang = _filterLanguage;
        double? tempMax = _maxPrice;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Bookstore Catalog',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempFormat = null;
                            tempLang = null;
                            tempMax = null;
                          });
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Format
                  const Text('Book Format', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: AppConstants.bookFormats.map((fmt) {
                      final isSel = tempFormat == fmt;
                      return ChoiceChip(
                        label: Text(fmt),
                        selected: isSel,
                        selectedColor: AppTheme.primaryBlue,
                        labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87),
                        onSelected: (val) {
                          setModalState(() => tempFormat = val ? fmt : null);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Language
                  const Text('Language Edition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: AppConstants.bookLanguages.map((lang) {
                      final isSel = tempLang == lang;
                      return ChoiceChip(
                        label: Text(lang),
                        selected: isSel,
                        selectedColor: AppTheme.primaryGreen,
                        labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87),
                        onSelected: (val) {
                          setModalState(() => tempLang = val ? lang : null);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Price
                  const Text('Maximum Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Slider(
                    value: tempMax ?? 1500,
                    min: 200,
                    max: 1500,
                    divisions: 13,
                    label: 'Up to Ksh ${(tempMax ?? 1500).toInt()}',
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      setModalState(() => tempMax = val);
                    },
                  ),
                  Center(
                    child: Text('Under Ksh ${(tempMax ?? 1500).toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                  ),
                  const SizedBox(height: 20),

                  // Apply
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _filterFormat = tempFormat;
                          _filterLanguage = tempLang;
                          _maxPrice = tempMax;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Literature Evangelism Store', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Filter Books',
            icon: Icon(
              Icons.tune,
              color: (_filterFormat != null || _filterLanguage != null || _maxPrice != null)
                  ? AppTheme.sacredGold
                  : Colors.white,
            ),
            onPressed: _showFilterModal,
          ),
          AnimatedBuilder(
            animation: cartService,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  if (cartService.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.sacredGold,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cartService.itemCount}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.sacredGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookstore_items').snapshots(),
        builder: (context, snapshot) {
          List<PhysicalBook> allBooks = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            allBooks = snapshot.data!.docs.map((doc) {
              return PhysicalBook.fromJson(doc.data() as Map<String, dynamic>, doc.id);
            }).toList();
          } else {
            allBooks = PhysicalBook.getSampleBooks();
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search title, author (Ellen White, etc.), subject...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              // Active filter tags row
              if (_filterFormat != null || _filterLanguage != null || _maxPrice != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text('Filters: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                      if (_filterFormat != null)
                        _buildActiveFilterChip(_filterFormat!, () => setState(() => _filterFormat = null)),
                      if (_filterLanguage != null)
                        _buildActiveFilterChip(_filterLanguage!, () => setState(() => _filterLanguage = null)),
                      if (_maxPrice != null)
                        _buildActiveFilterChip(
                            '≤ Ksh ${_maxPrice!.toInt()}', () => setState(() => _maxPrice = null)),
                    ],
                  ),
                ),

              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _categories.map((category) {
                    final books = _filterBooks(allBooks, category);

                    if (books.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No books found in "$category"',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                            ),
                            if (_searchQuery.isNotEmpty || _filterFormat != null)
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _filterFormat = null;
                                    _filterLanguage = null;
                                    _maxPrice = null;
                                  });
                                },
                                child: const Text('Clear Search & Filters'),
                              ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: books.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return _buildBookTile(context, book);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onDeleted,
        visualDensity: VisualDensity.compact,
        backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildBookTile(BuildContext context, PhysicalBook book) {
    final hasValidCover = book.coverImageUrl.isNotEmpty &&
        (book.coverImageUrl.startsWith('http://') || book.coverImageUrl.startsWith('https://'));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 80,
                  height: 115,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: hasValidCover
                      ? Image.network(
                          book.coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderCover(book),
                        )
                      : _buildPlaceholderCover(book),
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Favorite Row (Fixed with Flexible to prevent overflow)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: wishlistService,
                          builder: (context, _) {
                            final isFav = wishlistService.isFavorite(book.id);
                            return IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isFav ? Colors.redAccent : Colors.grey,
                              ),
                              onPressed: () => wishlistService.toggleFavorite(book.id),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'By ${book.author} • ${book.language}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),

                    // Format Tags: Hard copy and/or Soft copy badge
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        if (book.hasHardCopy)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: const Text('Hard Copy', style: TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.bold)),
                          ),
                        if (book.hasSoftCopy)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: const Text('Soft Copy (PDF)', style: TextStyle(fontSize: 9, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price & Order button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ksh ${book.price.toInt()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              if (book.hasDiscount)
                                Text(
                                  'Ksh ${book.originalPrice.toInt()}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: const Size(0, 34),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.add_shopping_cart, size: 14),
                          label: const Text('ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          onPressed: () {
                            cartService.addToCart(book);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('"${book.title}" added to cart!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.primaryGreen,
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'CHECKOUT',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CartScreen()),
                                    );
                                  },
                                ),
                              ),
                            );
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
    );
  }

  Widget _buildPlaceholderCover(PhysicalBook book) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories, color: AppTheme.sacredGold, size: 26),
          const SizedBox(height: 4),
          Text(
            book.format,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
