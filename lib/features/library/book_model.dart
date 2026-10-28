import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final String description;
  final String pdfUrl; // The link to the actual PDF file on Firebase Storage or web
  final String? onlineUrl; // Direct official EGW Writings / digital online reader link
  final String? series; // Thematic series or collection name
  final String? coverImageUrl;
  final double price; // 🚀 Replaces isPremium flag
  final DateTime publishedDate; // Crucial for sorting newest to oldest

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.pdfUrl,
    this.onlineUrl,
    this.series,
    this.coverImageUrl,
    this.price = 0.0, // Defaults to 0.0 (FREE)
    required this.publishedDate,
  });

  // 🚀 SMART GETTER: Automatically determines if it's locked based on price!
  bool get isPremium => price > 0;

  // 🌐 Helper to always get a valid online reading link
  String get effectiveOnlineUrl {
    if (onlineUrl != null && onlineUrl!.trim().isNotEmpty) {
      return onlineUrl!.trim();
    }
    if (pdfUrl.trim().startsWith('http://') || pdfUrl.trim().startsWith('https://')) {
      return pdfUrl.trim();
    }
    return 'https://m.egwwritings.org';
  }

  // Production-ready: Safely parses JSON from your backend/Firebase
  factory Book.fromJson(Map<String, dynamic> json, String documentId) {
    return Book(
      id: documentId, // We inject the actual Firebase ID here
      title: json['title'] as String? ?? 'Untitled',
      author: json['author'] as String? ?? 'Alfredo Onuko',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      pdfUrl: json['pdfUrl'] as String? ?? '',
      onlineUrl: json['onlineUrl'] as String?,
      series: json['series'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,

      // Safely parse numbers (Firebase sometimes stores 0.0 as an int)
      price: (json['price'] ?? 0).toDouble(),

      // CRITICAL FIX: Firebase stores dates as Timestamps, not Strings!
      publishedDate: json['publishedDate'] != null && json['publishedDate'] is Timestamp
          ? (json['publishedDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Prepares the data to be sent to the backend
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'category': category,
      'description': description,
      'pdfUrl': pdfUrl,
      'onlineUrl': onlineUrl,
      'series': series,
      'coverImageUrl': coverImageUrl,
      'price': price, // 🚀 Save the dynamic price
      // Convert Dart DateTime back to Firebase Timestamp
      'publishedDate': Timestamp.fromDate(publishedDate),
    };
  }

  // ==========================================
  // 🚀 THE SHARING ENGINE
  // ==========================================
  String generateShareText() {
    // Dynamic text based on whether it's free or paid
    String pricingInfo =
        isPremium ? "💰 Price: Ksh ${price.toInt()}" : "🎁 Free Christian Guide!";

    final readingLink = effectiveOnlineUrl;

    // 🚀 Updated Branding to HARVION
    return "📚 *HARVION: $title* 📚\n\n"
        "$description\n\n"
        "✍️ Author: $author\n"
        "📂 Category: $category\n"
        "${series != null ? "📖 Series: $series\n" : ""}"
        "$pricingInfo\n\n"
        "🌐 Read Online: $readingLink\n\n"
        "🌱 Read on the Harvion SDA Ministry App!";
  }
}
