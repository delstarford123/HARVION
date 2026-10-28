import 'package:flutter/foundation.dart';
import '../models/prayer_request_model.dart';

class PrayerWallService extends ChangeNotifier {
  static final PrayerWallService _instance = PrayerWallService._internal();
  factory PrayerWallService() => _instance;
  PrayerWallService._internal() {
    _initSamplePrayers();
  }

  final List<PrayerRequest> _prayers = [];

  List<PrayerRequest> get prayers => List.unmodifiable(_prayers);

  void addPrayerRequest({
    required String authorName,
    required bool isAnonymous,
    required String title,
    required String description,
    required String category,
  }) {
    final newPrayer = PrayerRequest(
      id: 'prayer_${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName,
      isAnonymous: isAnonymous,
      title: title,
      description: description,
      category: category,
      datePosted: DateTime.now(),
      prayerCount: 1,
      hasUserPrayed: true,
    );
    _prayers.insert(0, newPrayer);
    notifyListeners();
  }

  void togglePrayed(PrayerRequest request) {
    if (!request.hasUserPrayed) {
      request.prayerCount += 1;
      request.hasUserPrayed = true;
    } else {
      request.prayerCount = (request.prayerCount - 1).clamp(0, 99999);
      request.hasUserPrayed = false;
    }
    notifyListeners();
  }

  void _initSamplePrayers() {
    _prayers.addAll([
      PrayerRequest(
        id: 'pray_01',
        authorName: 'Sister Eunice Mutua',
        isAnonymous: false,
        title: 'Healing for My Mother Undergoing Surgery',
        description:
            'Please intercede for Mama Mary who is scheduled for cardiac surgery this Thursday. We pray the Great Physician guides the surgical team and brings full recovery to His glory.',
        category: 'Health & Healing',
        datePosted: DateTime.now().subtract(const Duration(hours: 4)),
        prayerCount: 28,
      ),
      PrayerRequest(
        id: 'pray_02',
        authorName: 'Brother Paul',
        isAnonymous: true,
        title: 'Youth Evangelistic Effort in Kisumu',
        description:
            'Our youth literature evangelism team is holding an open-air evangelistic series. Pray for the Holy Spirit to convict hearts and for souls to accept Christ.',
        category: 'Evangelism & Mission',
        datePosted: DateTime.now().subtract(const Duration(hours: 10)),
        prayerCount: 45,
      ),
      PrayerRequest(
        id: 'pray_03',
        authorName: 'Elder John Ombati',
        isAnonymous: false,
        title: 'Praise Report: Son Returned to Church!',
        description:
            'After 4 years of praying with this community, our son attended Divine Service and requested Bible studies. Praise God who answers persistent prayer!',
        category: 'Family & Salvation',
        datePosted: DateTime.now().subtract(const Duration(days: 1)),
        prayerCount: 73,
        isAnswered: true,
        praiseReport: 'Rejoicing in the Lord’s faithfulness!',
      ),
      PrayerRequest(
        id: 'pray_04',
        authorName: 'Sister Brenda',
        isAnonymous: false,
        title: 'Guidance in Financial Stewardship & Tithe',
        description:
            'Pray for our young family as we navigate economic challenges. We choose to remain faithful in tithes and offerings trusting Malachi 3:10.',
        category: 'Faith & Stewardship',
        datePosted: DateTime.now().subtract(const Duration(days: 2)),
        prayerCount: 39,
      ),
    ]);
  }
}

