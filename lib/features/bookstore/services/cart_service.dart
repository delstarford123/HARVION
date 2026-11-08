import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/physical_book_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];
  final List<BookstoreOrder> _orders = [];

  String? _appliedPromoCode;
  double _discountPercentage = 0.0;

  List<CartItem> get items => List.unmodifiable(_items);
  List<BookstoreOrder> get orders => List.unmodifiable(_orders);
  String? get appliedPromoCode => _appliedPromoCode;
  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);

  double get subtotal => _items.fold(0.0, (total, item) => total + item.totalPrice);
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

  Future<BookstoreOrder> createOrder({
    required String customerName,
    required String customerPhone,
    required String deliveryMethod,
    required String deliveryAddress,
    required String paymentMethod,
    String? deliveryTown,
    String? sdaChurchDepot,
  }) async {
    final orderId = 'HV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final now = DateTime.now();
    final estimated = now.add(const Duration(days: 2));

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
      paymentStatus: paymentMethod.contains('Cash') ? 'Pending Payment' : 'Paid (M-Pesa)',
      status: OrderStatus.confirmed,
      orderDate: now,
      estimatedDelivery: estimated,
      colporteurCode: _appliedPromoCode,
      deliveryRiderName: 'Brother Daniel (SDA Courier)',
      deliveryRiderPhone: '+254 745 090 990',
    );

    // 1. Save to Firebase Firestore collection 'orders'
    try {
      final orderMap = newOrder.toJson();
      if (deliveryTown != null) orderMap['deliveryTown'] = deliveryTown;
      if (sdaChurchDepot != null) orderMap['sdaChurchDepot'] = sdaChurchDepot;

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderMap);

      // 2. Decrement stock counts in Firestore for each physical book
      for (final item in _items) {
        if (item.book.id.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('bookstore_items')
              .doc(item.book.id)
              .update({'stockCount': FieldValue.increment(-item.quantity)})
              .catchError((_) {});
        }
      }

      // 3. Trigger Real-Time Admin Notification
      try {
        await FirebaseFirestore.instance.collection('admin_notifications').add({
          'type': 'new_order',
          'title': 'New Book Order: $orderId',
          'message': '$customerName ordered ${_items.length} book(s) - Ksh ${totalAmount.toStringAsFixed(0)} ($deliveryMethod)',
          'orderId': orderId,
          'customerPhone': customerPhone,
          'deliveryLocation': deliveryAddress,
          'totalAmount': totalAmount,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      } catch (_) {}
    } catch (e) {
      debugPrint('Firestore order save error (proceeding offline): $e');
    }

    _orders.insert(0, newOrder);
    clearCart();
    notifyListeners();
    return newOrder;
  }
}

