import 'package:cloud_firestore/cloud_firestore.dart';

class FarmingTopic {
  // 1. Core Identification
  final String id;
  final String title;
  final String category; // e.g., "Organic Fertilizer", "Pest Control"

  // 2. Content & Media
  final String shortDescription;
  final String content;
  final String? imageUrl;
  final String? videoTutorialUrl;

  // 3. Agronomy & Crop Specifics
  final String targetCrop;
  final String idealSoilType;
  final String optimalSeasons;
  final int growthDurationDays;

  // 4. Economics & Materials
  final List<String> requiredMaterials;
  final double estimatedCostKsh;
  final bool isPremium;

  // 5. Metadata
  final String author;
  final DateTime publishedDate;
  final int readTimeMinutes; // Now automatically calculated!

  FarmingTopic({
    required this.id,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.content,
    this.imageUrl,
    this.videoTutorialUrl,
    this.targetCrop = 'General',
    this.idealSoilType = 'Any',
    this.optimalSeasons = 'All Year',
    this.growthDurationDays = 0,
    this.requiredMaterials = const [],
    this.estimatedCostKsh = 0.0,
    this.isPremium = false,
    required this.author,
    required this.publishedDate,
    required this.readTimeMinutes,
  });

  // 🚀 UPGRADE 1: Bulletproof Parsing
  factory FarmingTopic.fromJson(Map<String, dynamic> json, String documentId) {
    // Safely extract the content string first so we can calculate read time if it's missing
    final String parsedContent = json['content'] as String? ?? '';

    return FarmingTopic(
      id: documentId,
      title: json['title'] as String? ?? 'Untitled Guide',
      category: json['category'] as String? ?? 'General Farming',
      shortDescription: json['shortDescription'] as String? ?? '',
      content: parsedContent,
      imageUrl: json['imageUrl'] as String?,
      videoTutorialUrl: json['videoTutorialUrl'] as String?,
      targetCrop: json['targetCrop'] as String? ?? 'General',
      idealSoilType: json['idealSoilType'] as String? ?? 'Any',
      optimalSeasons: json['optimalSeasons'] as String? ?? 'All Year',
      growthDurationDays: json['growthDurationDays'] as int? ?? 0,

      // 🛡️ Safe List Parsing: Prevents crashes if a null sneaks into the database array
      requiredMaterials: (json['requiredMaterials'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      // Safe number parsing
      estimatedCostKsh: (json['estimatedCostKsh'] ?? 0).toDouble(),
      isPremium: json['isPremium'] as bool? ?? false,
      author: json['author'] as String? ?? 'VINE Ministry',

      // Safe Timestamp parsing
      publishedDate:
          json['publishedDate'] != null && json['publishedDate'] is Timestamp
              ? (json['publishedDate'] as Timestamp).toDate()
              : DateTime.now(),

      // ⏱️ Auto-calculate read time if the database forgot to include it!
      readTimeMinutes:
          json['readTimeMinutes'] as int? ?? _calculateReadTime(parsedContent),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'shortDescription': shortDescription,
      'content': content,
      'imageUrl': imageUrl,
      'videoTutorialUrl': videoTutorialUrl,
      'targetCrop': targetCrop,
      'idealSoilType': idealSoilType,
      'optimalSeasons': optimalSeasons,
      'growthDurationDays': growthDurationDays,
      'requiredMaterials': requiredMaterials,
      'estimatedCostKsh': estimatedCostKsh,
      'isPremium': isPremium,
      'author': author,
      'publishedDate': Timestamp.fromDate(publishedDate),
      // Auto-calculate on upload as well!
      'readTimeMinutes':
          readTimeMinutes > 0 ? readTimeMinutes : _calculateReadTime(content),
    };
  }

  // ==========================================
  // 🛠️ HELPER METHODS (For a cleaner UI Codebase)
  // ==========================================

  // Calculates read time based on the average adult reading speed of 225 words per minute
  static int _calculateReadTime(String text) {
    if (text.isEmpty) return 1;
    int wordCount = text.trim().split(RegExp(r'\s+')).length;
    int minutes = (wordCount / 225).ceil();
    return minutes == 0 ? 1 : minutes;
  }

  // Gives you a clean date string (e.g., "14 Jan 2026") ready for the UI
  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${publishedDate.day} ${months[publishedDate.month - 1]} ${publishedDate.year}";
  }

  // ==========================================
  // 🚀 THE SHARING ENGINE
  // ==========================================
  String generateShareText() {
    String pricingInfo = isPremium
        ? "💰 Cost Est: Ksh ${estimatedCostKsh.toInt()}"
        : "🎁 Free Guide!";

    return "🌱 *VINE Farming Guides: $title* 🌱\n\n"
        "$shortDescription\n\n"
        "🌾 *Crop:* $targetCrop\n"
        "🌦️ *Best Season:* $optimalSeasons\n"
        "$pricingInfo\n\n"
        "📖 Read the full, step-by-step guide on the VINE App today!\n"
        "Download here: [Link to your PlayStore/Website]";
  }

  // ==========================================
  // 🔄 COPY WITH (For State Management & Editing)
  // ==========================================
  FarmingTopic copyWith({
    String? id,
    String? title,
    String? category,
    String? shortDescription,
    String? content,
    String? imageUrl,
    String? videoTutorialUrl,
    String? targetCrop,
    String? idealSoilType,
    String? optimalSeasons,
    int? growthDurationDays,
    List<String>? requiredMaterials,
    double? estimatedCostKsh,
    bool? isPremium,
    String? author,
    DateTime? publishedDate,
    int? readTimeMinutes,
  }) {
    return FarmingTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      shortDescription: shortDescription ?? this.shortDescription,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoTutorialUrl: videoTutorialUrl ?? this.videoTutorialUrl,
      targetCrop: targetCrop ?? this.targetCrop,
      idealSoilType: idealSoilType ?? this.idealSoilType,
      optimalSeasons: optimalSeasons ?? this.optimalSeasons,
      growthDurationDays: growthDurationDays ?? this.growthDurationDays,
      requiredMaterials: requiredMaterials ?? this.requiredMaterials,
      estimatedCostKsh: estimatedCostKsh ?? this.estimatedCostKsh,
      isPremium: isPremium ?? this.isPremium,
      author: author ?? this.author,
      publishedDate: publishedDate ?? this.publishedDate,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
    );
  }
}
