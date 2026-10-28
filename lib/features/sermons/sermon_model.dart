import 'package:cloud_firestore/cloud_firestore.dart';

enum SermonMediaType { audio, video }

class Sermon {
  final String id;
  final String title;
  final String speaker;
  final String description;
  final String mediaUrl; // URL to the MP3, MP4, YouTube, Google Drive, TikTok, or Stream
  final String? thumbnailUrl;
  final SermonMediaType type;
  final DateTime datePreached;
  final String seriesName; // e.g., "The Three Angels' Messages", "Family Life Sessions"
  final Duration duration;
  final double price; // Default is 0 (Free)
  final bool isLiveStream;
  final int liveViewerCount;
  final String videoSourceType; // 'youtube', 'tiktok', 'google_drive', 'direct'
  final String language; // e.g., "English", "Swahili", "French", "Spanish"
  final String ministryName; // e.g., "Berean Health & Truth", "Harvion Mission"
  final bool codeOfConductAccepted;

  Sermon({
    required this.id,
    required this.title,
    required this.speaker,
    required this.description,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.type,
    required this.datePreached,
    this.seriesName = "General Sermons",
    required this.duration,
    this.price = 0.0,
    this.isLiveStream = false,
    this.liveViewerCount = 0,
    this.videoSourceType = 'direct',
    this.language = 'English',
    this.ministryName = 'Harvion SDA Outpost',
    this.codeOfConductAccepted = true,
  });

  bool get isPremium => price > 0;

  /// Helper to extract YouTube video ID from URL
  String? get youtubeId {
    if (!isYouTube) return null;
    final uri = Uri.tryParse(mediaUrl);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (uri.host.contains('youtube.com')) {
      if (uri.pathSegments.contains('live')) {
        final idx = uri.pathSegments.indexOf('live');
        if (idx + 1 < uri.pathSegments.length) return uri.pathSegments[idx + 1];
      }
      return uri.queryParameters['v'];
    }
    return null;
  }

  /// Helper to detect if link is YouTube
  bool get isYouTube {
    final lower = mediaUrl.toLowerCase();
    return lower.contains('youtube.com') || lower.contains('youtu.be');
  }

  /// Helper to detect if link is TikTok
  bool get isTikTok {
    final lower = mediaUrl.toLowerCase();
    return lower.contains('tiktok.com') || videoSourceType == 'tiktok';
  }

  /// Helper to extract TikTok username handle
  String? get tikTokUsername {
    if (!isTikTok) return null;
    final cleanUrl = mediaUrl.trim();
    if (cleanUrl.startsWith('@')) return cleanUrl;
    final uri = Uri.tryParse(cleanUrl);
    if (uri != null) {
      for (final seg in uri.pathSegments) {
        if (seg.startsWith('@')) return seg;
      }
    }
    return null;
  }

  /// Direct link to TikTok Live
  String get tikTokLiveUrl {
    final clean = mediaUrl.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }
    final handle = clean.startsWith('@') ? clean : '@$clean';
    return 'https://www.tiktok.com/$handle/live';
  }

  /// Helper to detect if link is Google Drive
  bool get isGoogleDrive {
    final lower = mediaUrl.toLowerCase();
    return lower.contains('drive.google.com');
  }

  /// Helper to extract Google Drive file ID
  String? get googleDriveFileId {
    if (!isGoogleDrive) return null;
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(mediaUrl);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    final uri = Uri.tryParse(mediaUrl);
    return uri?.queryParameters['id'];
  }

  /// Formatted Google Drive stream URL or preview URL
  String get googleDriveDirectUrl {
    final fileId = googleDriveFileId;
    if (fileId != null) {
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return mediaUrl;
  }

  factory Sermon.fromJson(Map<String, dynamic> json, String documentId) {
    final url = json['mediaUrl'] ?? json['audioUrl'] ?? json['videoUrl'] ?? '';
    final isLive = json['isLiveStream'] as bool? ?? false;

    String sourceType = json['videoSourceType'] as String? ?? 'direct';
    final lower = url.toString().toLowerCase();
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      sourceType = 'youtube';
    } else if (lower.contains('tiktok.com') || sourceType == 'tiktok') {
      sourceType = 'tiktok';
    } else if (lower.contains('drive.google.com')) {
      sourceType = 'google_drive';
    }

    return Sermon(
      id: documentId,
      title: json['title'] as String? ?? 'Untitled Sermon',
      speaker: json['speaker'] as String? ?? 'Pastor / Speaker',
      description: json['description'] as String? ?? '',
      mediaUrl: url.toString(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      type: json['type'] == 'video' || isLive ? SermonMediaType.video : SermonMediaType.audio,
      datePreached: _parseDate(json),
      seriesName: json['seriesName'] as String? ?? 'General Sermons',
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      price: (json['price'] ?? 0).toDouble(),
      isLiveStream: isLive,
      liveViewerCount: json['liveViewerCount'] as int? ?? 0,
      videoSourceType: sourceType,
      language: json['language'] as String? ?? 'English',
      ministryName: json['ministryName'] as String? ?? 'Harvion SDA Outpost',
      codeOfConductAccepted: json['codeOfConductAccepted'] as bool? ?? true,
    );
  }

  static DateTime _parseDate(Map<String, dynamic> json) {
    if (json['publishedDate'] != null && json['publishedDate'] is Timestamp) {
      return (json['publishedDate'] as Timestamp).toDate();
    }
    if (json['datePreached'] != null && json['datePreached'] is Timestamp) {
      return (json['datePreached'] as Timestamp).toDate();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'speaker': speaker,
      'description': description,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'type': type == SermonMediaType.video ? 'video' : 'audio',
      'publishedDate': Timestamp.fromDate(datePreached),
      'seriesName': seriesName,
      'durationSeconds': duration.inSeconds,
      'price': price,
      'isLiveStream': isLiveStream,
      'liveViewerCount': liveViewerCount,
      'videoSourceType': videoSourceType,
      'language': language,
      'ministryName': ministryName,
      'codeOfConductAccepted': codeOfConductAccepted,
    };
  }

  String generateShareText() {
    return "🕊️ *$title* 🕊️\n"
        "Speaker: $speaker ($ministryName)\n"
        "Language: $language\n"
        "${isLiveStream ? '🔴 BROADCASTING LIVE NOW\n' : ''}"
        "Series: $seriesName\n\n"
        "Watch on the Harvion App:\n"
        "$mediaUrl";
  }

  String get formattedDuration {
    if (isLiveStream) return "LIVE";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
