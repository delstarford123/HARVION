import 'package:flutter/foundation.dart';
import '../models/physical_book_model.dart';

class WishlistService extends ChangeNotifier {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  final Set<String> _wishlistIds = {'sop_01', 'health_01'};

  Set<String> get wishlistIds => _wishlistIds;

  bool isFavorite(String bookId) => _wishlistIds.contains(bookId);

  void toggleFavorite(String bookId) {
    if (_wishlistIds.contains(bookId)) {
      _wishlistIds.remove(bookId);
    } else {
      _wishlistIds.add(bookId);
    }
    notifyListeners();
  }

  List<PhysicalBook> getFavoriteBooks(List<PhysicalBook> allBooks) {
    return allBooks.where((book) => _wishlistIds.contains(book.id)).toList();
  }
}

