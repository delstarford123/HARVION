import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import 'models/physical_book_model.dart';
import 'services/cart_service.dart';
import 'services/wishlist_service.dart';
import 'cart_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final PhysicalBook book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late String _selectedFormat;
  late String _selectedLanguage;
  int _quantity = 1;
  bool _isSoftCopySelected = false;

  @override
  void initState() {
    super.initState();
    _selectedFormat = widget.book.format;
    _selectedLanguage = widget.book.language;
    if (!widget.book.hasHardCopy && widget.book.hasSoftCopy) {
      _isSoftCopySelected = true;
    }
  }

  double get _currentPrice {
    if (_isSoftCopySelected && widget.book.softCopyPrice != null) {
      return widget.book.softCopyPrice!;
    }
    return widget.book.price;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();
    final wishlistService = WishlistService();
    final hasValidCover = widget.book.coverImageUrl.isNotEmpty &&
        (widget.book.coverImageUrl.startsWith('http://') || widget.book.coverImageUrl.startsWith('https://'));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          AnimatedBuilder(
            animation: wishlistService,
            builder: (context, _) {
              final isFav = wishlistService.isFavorite(widget.book.id);
              return IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.redAccent : Colors.white),
                onPressed: () {
                  wishlistService.toggleFavorite(widget.book.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isFav ? 'Removed from Wishlist' : 'Saved to Wishlist!'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                "📚 *${widget.book.title}* by ${widget.book.author}\n\n"
                "${widget.book.description}\n\n"
                "💰 Hard Copy: Ksh ${widget.book.price.toInt()} | Soft Copy: ${widget.book.hasSoftCopy ? 'Available' : 'N/A'}\n"
                "Order for home delivery or pick up at your local SDA church depot on Harvion App!\n"
                "https://harvion.app/book/${widget.book.id}",
              );
            },
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Showcase
            Center(
              child: Hero(
                tag: 'book_${widget.book.id}',
                child: Container(
                  width: 180,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: hasValidCover
                        ? Image.network(
                            widget.book.coverImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderCard(),
                          )
                        : _buildPlaceholderCard(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Preview Images Gallery
            if (widget.book.previewImages.isNotEmpty) ...[
              const Text('Sample Pages & Previews', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.book.previewImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final imgUrl = widget.book.previewImages[idx];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 70,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image, color: Colors.grey)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Edition Format Switcher (Hard Copy vs Soft Copy)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        if (widget.book.hasHardCopy) {
                          setState(() => _isSoftCopySelected = false);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isSoftCopySelected ? AppTheme.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.menu_book, size: 16, color: !_isSoftCopySelected ? Colors.white : Colors.black87),
                                const SizedBox(width: 4),
                                Text(
                                  'Hard Copy (${widget.book.hasHardCopy ? 'Available' : 'N/A'})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: !_isSoftCopySelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        if (widget.book.hasSoftCopy) {
                          setState(() => _isSoftCopySelected = true);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isSoftCopySelected ? AppTheme.primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.picture_as_pdf, size: 16, color: _isSoftCopySelected ? Colors.white : Colors.black87),
                                const SizedBox(width: 4),
                                Text(
                                  'Soft Copy (${widget.book.hasSoftCopy ? 'Instant' : 'N/A'})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _isSoftCopySelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category badge & rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.book.category,
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppTheme.sacredGold, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.book.rating} (SDA Verified)',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title and author
            Text(
              widget.book.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'By ${widget.book.author}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Price Row (Safe against small device overflow)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Ksh ${_currentPrice.toInt()}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    if (!_isSoftCopySelected && widget.book.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Ksh ${widget.book.originalPrice.toInt()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text(
                        _isSoftCopySelected ? 'Instant Soft Copy' : 'Hard Copy Ready',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Soft Copy Action Button
            if (_isSoftCopySelected && widget.book.softCopyUrl != null && widget.book.softCopyUrl!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('READ / OPEN DIGITAL SOFT COPY (EGW Writings)', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _launchUrl(widget.book.softCopyUrl!),
                ),
              ),

            // Colporteur / Seller Tag
            if (widget.book.sellerName != null && widget.book.sellerName!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.badge, color: AppTheme.primaryBlue, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sold by Literature Evangelist: ${widget.book.sellerName}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue)),
                          if (widget.book.sellerPhone != null)
                            Text('Contact: ${widget.book.sellerPhone}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Colporteur commission note if present
            if (widget.book.colporteurCommissionNote != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.sacredGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.sacredGold.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.volunteer_activism, color: Colors.amber, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Literature Evangelist Benefit: ${widget.book.colporteurCommissionNote}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Book Details Spec Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(child: _buildSpecItem('Pages', '${widget.book.pageCount}')),
                    Expanded(child: _buildSpecItem('Format', _isSoftCopySelected ? 'Digital PDF' : _selectedFormat)),
                    Expanded(child: _buildSpecItem('Language', _selectedLanguage)),
                    Expanded(child: _buildSpecItem('Access', _isSoftCopySelected ? 'Instant' : '1-2 Days')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Synopsis
            const Text(
              'Book Synopsis & Spiritual Mission',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.description,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Delivery Note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping, color: AppTheme.primaryBlue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Hard copy pickup available at Maxwell Book Centre & SDA Church Depots nationwide, or doorstep delivery. Soft copies available for instant reading.',
                      style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity controls (for hard copies)
              if (!_isSoftCopySelected) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() => _quantity -= 1);
                          }
                        },
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () {
                          setState(() => _quantity += 1);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // Add to Cart Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(
                    _isSoftCopySelected
                        ? 'GET SOFT COPY • Ksh ${_currentPrice.toInt()}'
                        : 'ADD TO CART • Ksh ${(_currentPrice * _quantity).toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: () {
                    final qty = _isSoftCopySelected ? 1 : _quantity;
                    for (int i = 0; i < qty; i++) {
                      cartService.addToCart(
                        widget.book,
                        format: _isSoftCopySelected ? 'Soft Copy (Digital)' : _selectedFormat,
                        language: _selectedLanguage,
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${widget.book.title}" added to cart!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppTheme.primaryGreen,
                        action: SnackBarAction(
                          label: 'VIEW CART',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 54, color: AppTheme.sacredGold),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.book.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
