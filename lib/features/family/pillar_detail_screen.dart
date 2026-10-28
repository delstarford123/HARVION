import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'models/family_pillar_model.dart';
import '../sermons/sermon_model.dart';
import '../sermons/video_player_screen.dart';

class PillarDetailScreen extends StatelessWidget {
  final FamilyPillar pillar;

  const PillarDetailScreen({super.key, required this.pillar});

  Future<void> _launchVideo(BuildContext context, String url) async {
    // If it's a video link, open directly in our VideoPlayerScreen!
    final sermon = Sermon(
      id: 'family_${pillar.id}',
      title: '${pillar.title} - Family Teaching Session',
      speaker: 'Harvion Family Life Ministry',
      description: pillar.description,
      mediaUrl: url,
      type: SermonMediaType.video,
      datePreached: DateTime.now(),
      seriesName: 'Adventist Home Pillars',
      duration: const Duration(minutes: 45),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(sermon: sermon)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(pillar.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: pillar.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                "🏡 *${pillar.title}* — Pillars of the Adventist Home\n\n"
                "${pillar.description}\n\n"
                "📜 *Spirit of Prophecy:*\n\"${pillar.egwQuote}\"\n— ${pillar.egwSource}\n\n"
                "Explore Adventist family principles on Harvion:\n"
                "https://harvion.app/family/${pillar.id}",
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Pillar Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [pillar.color, pillar.color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: pillar.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(pillar.iconData, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    pillar.title,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pillar.subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Overview & Description
            const Text(
              'Sacred Foundation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 8),
            Text(
              pillar.description,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Video / Teaching Session Button (if available)
            if (pillar.videoLink != null && pillar.videoLink!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: pillar.color.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_circle_fill, color: Colors.red, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Family Video & Livestream Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Watch pastoral seminar & Q&A', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _launchVideo(context, pillar.videoLink!),
                      child: const Text('WATCH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Spirit of Prophecy Quotation Card
            if (pillar.egwQuote.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.sacredGold.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.format_quote, color: AppTheme.sacredGold, size: 24),
                        SizedBox(width: 8),
                        Text('Spirit of Prophecy Counsel',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${pillar.egwQuote}"',
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.6, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '— ${pillar.egwSource}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Key Scriptures
            if (pillar.keyScriptures.isNotEmpty) ...[
              const Text(
                'Scriptural Anchor Texts',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pillar.keyScriptures.map((scr) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.book, size: 14, color: AppTheme.primaryBlue),
                        const SizedBox(width: 6),
                        Text(scr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Practical Action Steps
            if (pillar.actionSteps.isNotEmpty) ...[
              const Text(
                'Practical Home Implementation Steps',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 10),
              ...pillar.actionSteps.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.primaryGreen,
                        child: Text('$idx', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
