import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import 'models/family_pillar_model.dart';
import 'pillar_detail_screen.dart';
import '../sermons/sermon_model.dart';
import '../sermons/video_player_screen.dart';

class FamilyLifeScreen extends StatelessWidget {
  const FamilyLifeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Family Life & Home Outpost',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 24),

            // Live Livestream / Featured Teaching Banner
            _buildFamilyVideoBanner(context),
            const SizedBox(height: 24),

            _buildSectionTitle('Pillars of the Adventist Home'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: Text(
                'Tap any pillar to explore Biblical foundations, Spirit of Prophecy counsel, and practical family guides.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            _buildPillarsGrid(context),
            const SizedBox(height: 32),

            _buildSectionTitle('Featured Counsel & Parenting Articles'),
            _buildFeaturedArticles(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.family_restroom, color: AppTheme.sacredGold, size: 54),
          const SizedBox(height: 14),
          const Text(
            '"The restoration and uplifting of humanity begins in the home... The well-being of society, the success of the church, the prosperity of the nation, depend upon home influences."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The Ministry of Healing, p. 349',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.sacredGold.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyVideoBanner(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sermons')
          .where('seriesName', isEqualTo: 'Family Life Sessions')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        Sermon? familySession;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final doc = snapshot.data!.docs.first;
          familySession = Sermon.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        } else {
          familySession = Sermon(
            id: 'family_live_01',
            title: 'Building an Edenic Home: Love, Worship & Wholesome Diet',
            speaker: 'Pastor Alfredo Onuko & Family Life Ministry',
            description: 'A practical, spiritually uplifting study on establishing daily family worship and healthy meal habits.',
            mediaUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            type: SermonMediaType.video,
            datePreached: DateTime.now(),
            seriesName: 'Family Life Sessions',
            duration: const Duration(minutes: 50),
            isLiveStream: true,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade900, AppTheme.primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.purple.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.live_tv, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('FAMILY BROADCAST', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        familySession.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        familySession.speaker,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.sacredGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VideoPlayerScreen(sermon: familySession!)),
                    );
                  },
                  child: const Text('WATCH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPillarsGrid(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('family_pillars').orderBy('orderIndex').snapshots(),
      builder: (context, snapshot) {
        List<FamilyPillar> pillars = [];

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          pillars = snapshot.data!.docs.map((doc) {
            return FamilyPillar.fromJson(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        } else {
          pillars = FamilyPillar.getMockPillars();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemCount: pillars.length,
            itemBuilder: (context, index) {
              final pillar = pillars[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PillarDetailScreen(pillar: pillar),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          pillar.color.withOpacity(0.12),
                          pillar.color.withOpacity(0.04),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: pillar.color.withOpacity(0.15),
                          child: Icon(pillar.iconData, color: pillar.color, size: 28),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pillar.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary.withOpacity(0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'View Dedicated Guide →',
                          style: TextStyle(fontSize: 9, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeaturedArticles(BuildContext context) {
    final articles = [
      {
        'title': 'Building a Strong Marriage Foundation in the Last Days',
        'time': '5 min read',
        'author': 'The Adventist Home, ch. 2',
        'link': 'pillar_marriage',
      },
      {
        'title': 'Guiding Children Away from Digital Traps',
        'time': '7 min read',
        'author': 'Child Guidance, ch. 14',
        'link': 'pillar_parenting',
      },
      {
        'title': 'The Family Altar: Reviving Morning and Evening Worship',
        'time': '4 min read',
        'author': 'Ministry of Healing, p. 392',
        'link': 'pillar_family_altar',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      itemBuilder: (context, index) {
        final art = articles[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              art['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${art['author']} • ${art['time']}',
                style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 11),
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primaryBlue),
            onTap: () {
              final mock = FamilyPillar.getMockPillars().firstWhere(
                (p) => p.id == art['link'],
                orElse: () => FamilyPillar.getMockPillars().first,
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PillarDetailScreen(pillar: mock)),
              );
            },
          ),
        );
      },
    );
  }
}
