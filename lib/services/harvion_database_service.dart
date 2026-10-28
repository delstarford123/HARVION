import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../features/bookstore/models/physical_book_model.dart';
import '../features/devotional/models/devotional_model.dart';
import '../features/recipes/models/recipe_model.dart';
import '../features/church_directory/models/church_model.dart';
import '../features/tracts/models/tract_model.dart';
import '../features/family/models/family_pillar_model.dart';

class HarvionDatabaseService {
  static final HarvionDatabaseService _instance = HarvionDatabaseService._internal();
  factory HarvionDatabaseService() => _instance;
  HarvionDatabaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Seeds all collections in Firebase Firestore for project `vine-3e4ab`
  Future<Map<String, int>> seedCompleteFirebaseDatabase({
    void Function(String message)? onProgress,
  }) async {
    final Map<String, int> results = {};

    try {
      // 1. Seed Bookstore Catalog (Literature Evangelism)
      onProgress?.call('Writing books to bookstore_items...');
      final sampleBooks = PhysicalBook.getSampleBooks();
      int booksCount = 0;
      for (final book in sampleBooks) {
        await _db.collection(AppConstants.colBookstore).doc(book.id).set(book.toJson(), SetOptions(merge: true));
        booksCount++;
      }
      results['bookstore_items'] = booksCount;

      // 2. Seed Family Life Pillars
      onProgress?.call('Writing Pillars of the Adventist Home...');
      final samplePillars = FamilyPillar.getMockPillars();
      int pillarCount = 0;
      for (final p in samplePillars) {
        await _db.collection('family_pillars').doc(p.id).set(p.toJson(), SetOptions(merge: true));
        pillarCount++;
      }
      results['family_pillars'] = pillarCount;

      // 3. Seed Camp Meeting Colporteur Outposts
      onProgress?.call('Writing Camp Meeting book stands...');
      await _db.collection('camp_meeting_locations').doc('loc_maxwell_01').set({
        'colporteurName': 'Alfredo Onuko',
        'phone': '0745090990',
        'eventName': 'Central Kenya Conference Camp Meeting',
        'boothLocation': 'Literature Evangelism Tent #4 (Near Maxwell Book Stand)',
        'city': 'Nairobi',
        'description': 'Come get your Spirit of Prophecy sets, The Great Controversy, health guides, and Edenic farming handbooks! Hard copies and instant soft copies available.',
        'hasHardCopy': true,
        'hasSoftCopy': true,
        'status': 'Active Now',
        'postedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _db.collection('camp_meeting_locations').doc('loc_kisumu_01').set({
        'colporteurName': 'Sister Grace Wanjiru',
        'phone': '0711223344',
        'eventName': 'Western Kenya Camp Meeting & Evangelistic Outpost',
        'boothLocation': 'Exhibition Pavillion Booth B12, Kisumu Grounds',
        'city': 'Kisumu',
        'description': 'Special discounts for church quarterly bulk orders, missionary tracts, and children\'s Bedtime Stories sets.',
        'hasHardCopy': true,
        'hasSoftCopy': true,
        'status': 'Active Now',
        'postedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      results['camp_meeting_locations'] = 2;

      // 4. Seed Sermons & Livestreams
      onProgress?.call('Writing sermons & live video sessions...');
      await _db.collection('sermons').doc('sermon_live_01').set({
        'title': 'LIVE: Sabbath Morning Divine Service & Revival Session',
        'speaker': 'Pastor Alfredo Onuko',
        'description': 'Join us live for an inspiring Sabbath worship experience and deep study of the Sanctuary truth.',
        'mediaUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'videoSourceType': 'youtube',
        'isLiveStream': true,
        'type': 'video',
        'seriesName': 'Sabbath Live Broadcast',
        'durationSeconds': 3600,
        'price': 0.0,
        'publishedDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _db.collection('sermons').doc('sermon_family_01').set({
        'title': 'Building an Edenic Home: Love, Worship & Wholesome Diet',
        'speaker': 'Harvion Family Life Ministry',
        'description': 'A practical, spiritually uplifting study on establishing daily family worship and healthy meal habits.',
        'mediaUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'videoSourceType': 'youtube',
        'isLiveStream': false,
        'type': 'video',
        'seriesName': 'Family Life Sessions',
        'durationSeconds': 3000,
        'price': 0.0,
        'publishedDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      results['sermons'] = 2;

      // 5. Seed Daily Devotionals & Daily Quotes
      onProgress?.call('Writing morning devotionals & daily quotes...');
      final sampleDevotionals = DailyDevotional.getRecentDevotionals();
      int devCount = 0;
      for (final dev in sampleDevotionals) {
        await _db.collection('devotionals').doc(dev.id).set({
          'title': dev.title,
          'scriptureReference': dev.scriptureReference,
          'scriptureText': dev.scriptureText,
          'commentary': dev.commentary,
          'author': dev.author,
          'prayerThought': dev.prayerThought,
          'date': Timestamp.fromDate(dev.date),
        }, SetOptions(merge: true));

        await _db.collection(AppConstants.colDailyQuotes).doc('quote_${dev.id}').set({
          'text': dev.commentary,
          'reference': dev.author,
          'displayDate': Timestamp.fromDate(dev.date),
        }, SetOptions(merge: true));
        devCount++;
      }
      results['devotionals'] = devCount;

      // 6. Seed Colporteurs
      onProgress?.call('Writing Literature Evangelists & referral codes...');
      await _db.collection(AppConstants.colColporteurs).doc('LE-ALFREDO').set({
        'leId': 'LE-KE-2026-042',
        'name': 'Alfredo Onuko',
        'churchConference': 'Central Kenya Conference (CKC) - Publishing Dept',
        'referralCode': 'COLP-ALFREDO10',
        'totalSalesCommission': 14850.0,
        'booksDistributed': 64,
        'activeCustomers': 28,
        'commissionRate': 0.25,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      results['colporteurs'] = 1;

      // 7. Seed Healthy Recipes
      onProgress?.call('Writing plant-based recipes & meal planner...');
      final sampleRecipes = HealthyRecipe.getSampleRecipes();
      int recCount = 0;
      for (final rec in sampleRecipes) {
        await _db.collection(AppConstants.colRecipes).doc(rec.id).set({
          'title': rec.title,
          'category': rec.category,
          'description': rec.description,
          'prepTimeMinutes': rec.prepTimeMinutes,
          'cookTimeMinutes': rec.cookTimeMinutes,
          'servings': rec.servings,
          'ingredients': rec.ingredients,
          'instructions': rec.instructions,
          'healthBenefits': rec.healthBenefits,
          'linkedBookstoreBookId': rec.linkedBookstoreBookId,
          'linkedBookTitle': rec.linkedBookTitle,
        }, SetOptions(merge: true));
        recCount++;
      }
      results['healthy_recipes'] = recCount;

      // 8. Seed Churches Directory
      onProgress?.call('Writing SDA Church & event directory...');
      final sampleChurches = SdaChurch.getSampleChurches();
      int chuCount = 0;
      for (final chu in sampleChurches) {
        await _db.collection(AppConstants.colChurches).doc(chu.id).set({
          'name': chu.name,
          'conference': chu.conference,
          'city': chu.city,
          'address': chu.address,
          'pastorName': chu.pastorName,
          'pastorPhone': chu.pastorPhone,
          'clerkPhone': chu.clerkPhone,
          'email': chu.email,
          'serviceTimes': chu.serviceTimes,
          'upcomingEvents': chu.upcomingEvents,
          'hasBookstoreDepot': chu.hasBookstoreDepot,
          'latitude': chu.latitude,
          'longitude': chu.longitude,
        }, SetOptions(merge: true));
        chuCount++;
      }
      results['churches_directory'] = chuCount;

      // 9. Seed Community Prayer Requests
      onProgress?.call('Writing community prayers...');
      await _db.collection(AppConstants.colPrayerRequests).doc('pray_01').set({
        'authorName': 'Sister Eunice Mutua',
        'isAnonymous': false,
        'title': 'Healing for My Mother Undergoing Surgery',
        'description':
            'Please intercede for Mama Mary who is scheduled for cardiac surgery this Thursday. We pray the Great Physician guides the surgical team and brings full recovery to His glory.',
        'category': 'Health & Healing',
        'datePosted': FieldValue.serverTimestamp(),
        'prayerCount': 28,
        'isAnswered': false,
      }, SetOptions(merge: true));
      results['prayer_requests'] = 1;

      // 10. Seed Digital Tracts
      onProgress?.call('Writing digital evangelism tracts...');
      final sampleTracts = DigitalTract.getSampleTracts();
      int tractCount = 0;
      for (final tract in sampleTracts) {
        await _db.collection(AppConstants.colDigitalTracts).doc(tract.id).set({
          'title': tract.title,
          'subtitle': tract.subtitle,
          'category': tract.category,
          'summary': tract.summary,
          'fullText': tract.fullText,
          'keyVerse': tract.keyVerse,
          'shareCardQuote': tract.shareCardQuote,
          'shareCount': tract.shareCount,
        }, SetOptions(merge: true));
        tractCount++;
      }
      results['digital_tracts'] = tractCount;

      onProgress?.call('Database initialized successfully!');
      return results;
    } catch (e) {
      debugPrint('Error during Firestore database seeding: $e');
      rethrow;
    }
  }

  /// Check if the database has already been seeded
  Future<bool> isDatabaseSeeded() async {
    try {
      final snapshot = await _db.collection(AppConstants.colBookstore).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
