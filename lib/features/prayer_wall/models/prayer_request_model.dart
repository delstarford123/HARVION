import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerRequest {
  final String id;
  final String authorName;
  final bool isAnonymous;
  final String title;
  final String description;
  final String category; // 'Health & Healing', 'Family', 'Evangelism', 'Salvation'
  final DateTime datePosted;
  int prayerCount;
  bool hasUserPrayed;
  final bool isAnswered;
  final String? praiseReport;

  PrayerRequest({
    required this.id,
    required this.authorName,
    this.isAnonymous = false,
    required this.title,
    required this.description,
    required this.category,
    required this.datePosted,
    this.prayerCount = 0,
    this.hasUserPrayed = false,
    this.isAnswered = false,
    this.praiseReport,
  });

  String get displayName => isAnonymous ? 'A Fellow Believer' : authorName;

  factory PrayerRequest.fromJson(Map<String, dynamic> json, String documentId) {
    return PrayerRequest(
      id: documentId,
      authorName: json['authorName'] as String? ?? 'Anonymous',
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      title: json['title'] as String? ?? 'Prayer Request',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      datePosted: json['datePosted'] != null && json['datePosted'] is Timestamp
          ? (json['datePosted'] as Timestamp).toDate()
          : DateTime.now(),
      prayerCount: json['prayerCount'] as int? ?? 0,
      hasUserPrayed: false,
      isAnswered: json['isAnswered'] as bool? ?? false,
      praiseReport: json['praiseReport'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorName': authorName,
      'isAnonymous': isAnonymous,
      'title': title,
      'description': description,
      'category': category,
      'datePosted': Timestamp.fromDate(datePosted),
      'prayerCount': prayerCount,
      'isAnswered': isAnswered,
      'praiseReport': praiseReport,
    };
  }
}

