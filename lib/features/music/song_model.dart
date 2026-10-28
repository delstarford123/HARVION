import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String id;
  final String title;
  final String artist; // In Firebase, we saved this as 'speaker'
  final String audioUrl;
  final double price; // 🚀 Replaces isPremium flag
  final DateTime publishedDate;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    this.price = 0.0, // Defaults to 0.0 (FREE)
    required this.publishedDate,
  });

  // 🚀 SMART GETTER: Automatically determines if it's locked based on price!
  bool get isPremium => price > 0;

  // Production-ready: Safely parses JSON from Firebase
  factory Song.fromJson(Map<String, dynamic> json, String documentId) {
    return Song(
      id: documentId,
      title: json['title'] as String? ?? 'Untitled Audio',
      // Maps 'speaker' from Admin Panel to 'artist' here
      artist: json['speaker'] as String? ??
          json['artist'] as String? ??
          'Alfredo Onuko', // 🚀 Updated default
      audioUrl: json['audioUrl'] as String? ?? '',

      // Safely parse numbers (Firebase sometimes stores 0.0 as an int)
      price: (json['price'] ?? 0).toDouble(),

      // CRITICAL FIX: Firebase stores dates as Timestamps
      publishedDate:
          json['publishedDate'] != null && json['publishedDate'] is Timestamp
              ? (json['publishedDate'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  // Prepares the data to be sent to the backend
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'speaker': artist, // Save back as 'speaker' to match Admin DB structure
      'audioUrl': audioUrl,
      'price': price, //  Save the dynamic price
      'publishedDate': Timestamp.fromDate(publishedDate),
    };
  }

  // ==========================================
  // 🚀 THE SHARING ENGINE
  // ==========================================
  String generateShareText() {
    String pricingInfo =
        isPremium ? " Price: Ksh ${price.toInt()}" : "🎁 Free Audio!";

    // 🚀 Updated Branding to HARVION
    return "*HARVION: $title* \n\n"
        "Speaker: $artist\n"
        "$pricingInfo\n\n"
        "Listen to the full audio on the Harvion App today!";
  }
}
