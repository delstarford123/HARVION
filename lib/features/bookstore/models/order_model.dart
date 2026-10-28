import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

enum OrderStatus {
  confirmed,
  processing,
  dispatched,
  inTransit,
  delivered,
  cancelled,
}

class BookstoreOrder {
  final String orderId;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final String customerName;
  final String customerPhone;
  final String deliveryMethod; // 'Church Pickup Station' or 'Doorstep Rider'
  final String deliveryAddress;
  final String paymentMethod; // 'M-Pesa', 'Credit/Debit Card', 'Cash on Delivery'
  final String paymentStatus; // 'Paid', 'Pending'
  OrderStatus status;
  final DateTime orderDate;
  final DateTime estimatedDelivery;
  final String? colporteurCode;
  final String? deliveryRiderName;
  final String? deliveryRiderPhone;

  BookstoreOrder({
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.discount = 0.0,
    required this.totalAmount,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryMethod,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.paymentStatus = 'Paid',
    this.status = OrderStatus.confirmed,
    required this.orderDate,
    required this.estimatedDelivery,
    this.colporteurCode,
    this.deliveryRiderName,
    this.deliveryRiderPhone,
  });

  String get statusDisplay {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.processing:
        return 'Packing & Preparation';
      case OrderStatus.dispatched:
        return 'Dispatched from Depot';
      case OrderStatus.inTransit:
        return 'In Transit with Rider';
      case OrderStatus.delivered:
        return 'Delivered / Ready for Pickup';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get statusStepIndex {
    switch (status) {
      case OrderStatus.confirmed:
        return 0;
      case OrderStatus.processing:
        return 1;
      case OrderStatus.dispatched:
        return 2;
      case OrderStatus.inTransit:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return 0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryMethod': deliveryMethod,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'status': status.name,
      'orderDate': Timestamp.fromDate(orderDate),
      'estimatedDelivery': Timestamp.fromDate(estimatedDelivery),
      'colporteurCode': colporteurCode,
      'deliveryRiderName': deliveryRiderName,
      'deliveryRiderPhone': deliveryRiderPhone,
    };
  }
}

