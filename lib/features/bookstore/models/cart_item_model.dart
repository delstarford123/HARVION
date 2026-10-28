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
      'unitPrice': book.price,
      'quantity': quantity,
      'selectedFormat': selectedFormat,
      'selectedLanguage': selectedLanguage,
    };
  }
}

