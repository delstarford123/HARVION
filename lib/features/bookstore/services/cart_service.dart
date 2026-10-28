import 'package:flutter/foundation.dart';
import '../models/physical_book_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal() {
    _initSampleOrders();
  }

  final List<CartItem> _items = [];
  final List<BookstoreOrder> _orders = [];

  String? _appliedPromoCode;
  double _discountPercentage = 0.0;

  List<CartItem> get items => List.unmodifiable(_items);
  List<BookstoreOrder> get orders => List.unmodifiable(_orders);
  String? get appliedPromoCode => _appliedPromoCode;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get discountAmount => subtotal * _discountPercentage;
  double get deliveryFee => _items.isEmpty ? 0.0 : 250.0; // Standard local delivery
  double get totalAmount => (subtotal - discountAmount + deliveryFee).clamp(0.0, double.infinity);

  void addToCart(PhysicalBook book, {String format = 'Paperback', String language = 'English'}) {
    final existingIndex = _items.indexWhere(
      (item) => item.book.id == book.id && item.selectedFormat == format && item.selectedLanguage == language,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(
        CartItem(
          book: book,
          quantity: 1,
          selectedFormat: format,
          selectedLanguage: language,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int delta) {
    item.quantity += delta;
    if (item.quantity <= 0) {
      _items.remove(item);
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedPromoCode = null;
    _discountPercentage = 0.0;
    notifyListeners();
  }

  bool applyPromoCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean.startsWith('COLP-') || clean == 'MINISTRY10' || clean == 'SDA10') {
      _appliedPromoCode = clean;
      _discountPercentage = 0.10; // 10% discount for ministry / colporteur referral
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromoCode() {
    _appliedPromoCode = null;
    _discountPercentage = 0.0;
    notifyListeners();
  }

  BookstoreOrder createOrder({
    required String customerName,
    required String customerPhone,
    required String deliveryMethod,
    required String deliveryAddress,
    required String paymentMethod,
  }) {
    final orderId = 'VIN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final newOrder = BookstoreOrder(
      orderId: orderId,
      items: List.from(_items),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discountAmount,
      totalAmount: totalAmount,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryMethod: deliveryMethod,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'Cash on Delivery / Church Pickup' ? 'Pending' : 'Paid',
      status: OrderStatus.confirmed,
      orderDate: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
      colporteurCode: _appliedPromoCode,
      deliveryRiderName: 'Brother Daniel (SDA Courier)',
      deliveryRiderPhone: '+254 712 345 678',
    );

    _orders.insert(0, newOrder);
    clearCart();
    notifyListeners();
    return newOrder;
  }

  void _initSampleOrders() {
    final sampleBooks = PhysicalBook.getSampleBooks();
    _orders.add(
      BookstoreOrder(
        orderId: 'VIN-89342',
        items: [
          CartItem(
            book: sampleBooks[0],
            quantity: 1,
            selectedFormat: 'Hardcover',
            selectedLanguage: 'English',
          ),
          CartItem(
            book: sampleBooks[2],
            quantity: 2,
            selectedFormat: 'Pocket Size',
            selectedLanguage: 'Kiswahili',
          ),
        ],
        subtotal: 1550.0,
        deliveryFee: 200.0,
        discount: 155.0,
        totalAmount: 1595.0,
        customerName: 'Alfredo Onuko',
        customerPhone: '0745090990',
        deliveryMethod: 'Nairobi Central SDA Church Depot',
        deliveryAddress: 'Maxwell Adventist Book Centre Pickup',
        paymentMethod: 'M-Pesa (Mobile Money)',
        status: OrderStatus.inTransit,
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        estimatedDelivery: DateTime.now().add(const Duration(hours: 4)),
        colporteurCode: 'COLP-ALFREDO10',
        deliveryRiderName: 'Brother Daniel (SDA Courier)',
        deliveryRiderPhone: '0712345678',
      ),
    );
  }
}

