import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../bookstore/models/physical_book_model.dart';
import '../bookstore/services/cart_service.dart';
import '../bookstore/services/wishlist_service.dart';
import '../bookstore/book_detail_screen.dart';
import '../bookstore/cart_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistService = WishlistService();
    final cartService = CartService();
    final allBooks = PhysicalBook.getSampleBooks();

    return AnimatedBuilder(
      animation: wishlistService,
      builder: (context, _) {
        final favoriteBooks = wishlistService.getFavoriteBooks(allBooks);

        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          appBar: AppBar(
            title: const Text('My Saved Books & Wishlist', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
            ],
          ),
          body: favoriteBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 70, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'Your Wishlist is Empty',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap the heart icon on any book in the bookstore to save it here.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: favoriteBooks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final book = favoriteBooks[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 50,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.menu_book, color: AppTheme.primaryBlue, size: 24),
                        ),
                        title: Text(
                          book.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(book.author, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                            const SizedBox(height: 4),
                            Text(
                              'Ksh ${book.price.toInt()} (${book.format})',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 13),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart, color: AppTheme.primaryGreen),
                              tooltip: 'Add to Cart',
                              onPressed: () {
                                cartService.addToCart(book);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${book.title}" added to cart!'),
                                    backgroundColor: AppTheme.primaryGreen,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Remove',
                              onPressed: () => wishlistService.toggleFavorite(book.id),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

