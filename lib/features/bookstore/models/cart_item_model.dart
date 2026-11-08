import 'physical_book_model.dart';

class CartItem {
  final PhysicalBook book;
  int quantity;
  String selectedFormat;
  String selectedLanguage;

  CartItem({
    required this.book,
    this.quantity = 1,
    required this.selectedFormat,
    required this.selectedLanguage,
  });

  double get totalPrice => book.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'bookId': book.id,
      'title': book.title,
      'author': book.author,
      'coverImageUrl': book.coverImageUrl,
      'unitPrice': book.price,
      'quantity': quantity,
      'selectedFormat': selectedFormat,
      'selectedLanguage': selectedLanguage,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      book: PhysicalBook(
        id: json['bookId'] as String? ?? '',
        title: json['title'] as String? ?? 'Adventist Publication',
        author: json['author'] as String? ?? 'Ellen G. White',
        category: json['category'] as String? ?? 'Spirit of Prophecy',
        description: '',
        price: (json['unitPrice'] as num? ?? 0.0).toDouble(),
        coverImageUrl: json['coverImageUrl'] as String? ?? '',
      ),
      quantity: json['quantity'] as int? ?? 1,
      selectedFormat: json['selectedFormat'] as String? ?? 'Hardcover',
      selectedLanguage: json['selectedLanguage'] as String? ?? 'English',
    );
  }
}

