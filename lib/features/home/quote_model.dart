import 'package:cloud_firestore/cloud_firestore.dart';

class DailyQuote {
  final String id;
  final String text;
  final String reference;
  final DateTime displayDate;
  final String? backgroundImageUrl;

  DailyQuote({
    required this.id,
    required this.text,
    required this.reference,
    required this.displayDate,
    this.backgroundImageUrl,
  });

  // Production-ready: Safely parses JSON from your backend/Firebase
  factory DailyQuote.fromJson(Map<String, dynamic> json, String documentId) {
    return DailyQuote(
      id: documentId,
      text: json['text'] as String? ?? 'No quote available today.',
      reference: json['reference'] as String? ?? 'Unknown Source',

      // CRITICAL FIX: Firebase stores dates as Timestamps, not Strings!
      displayDate:
          json['displayDate'] != null && json['displayDate'] is Timestamp
              ? (json['displayDate'] as Timestamp).toDate()
              : DateTime.now(),

      backgroundImageUrl: json['backgroundImageUrl'] as String?,
    );
  }

  // Prepares the data to be sent to the backend
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'reference': reference,
      // Convert Dart DateTime back to Firebase Timestamp
      'displayDate': Timestamp.fromDate(displayDate),
      'backgroundImageUrl': backgroundImageUrl,
    };
  }

  // ==========================================
  // 🚀 THE SHARING ENGINE
  // ==========================================
  String generateShareText() {
    return "📖 *VINE Daily Grace* 📖\n\n"
        "\"$text\"\n\n"
        "- $reference\n\n"
        "🌱 Get daily inspiration and organic farming guides. "
        "Download the VINE App today!";
  }
}
