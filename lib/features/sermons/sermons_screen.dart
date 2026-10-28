import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'sermon_model.dart';
import 'video_player_screen.dart';
import 'create_livestream_screen.dart';
import '../music/song_model.dart';
import '../music/music_player_screen.dart';
import '../music/audio_detail_screen.dart';

class SermonsScreen extends StatelessWidget {
  const SermonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Sermons & Broadcasts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            icon: const Icon(Icons.podcasts, size: 16, color: Colors.white),
            label: const Text('GO LIVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateLiveStreamScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.videocam),
        label: const Text('START LIVE STREAM', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateLiveStreamScreen()),
          );
        },
      ),
      body: CustomScrollView(
        slivers: [
          // Professional App Header Hero
          SliverToBoxAdapter(
            child: _buildHeroSection(context),
          ),

          // Active Live Broadcasts Row (from Firestore)
          SliverToBoxAdapter(
            child: _buildActiveLiveStreamSection(context),
          ),

          // Search & Filter Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  const Text(
                    "All Teachings & Media",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SDA Broadcasts',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // THE FIREBASE TUNNEL FOR SERMONS
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('sermons')
                .orderBy('publishedDate', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic_off, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No sermons uploaded yet.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final List<Sermon> sermons = snapshot.data!.docs.map((doc) {
                return Sermon.fromJson(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildSermonTile(context, sermons[index]);
                  },
                  childCount: sermons.length,
                ),
              );
            },
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  Widget _buildActiveLiveStreamSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sermons')
          .where('isLiveStream', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final liveSermons = snapshot.data!.docs.map((d) {
          return Sermon.fromJson(d.data() as Map<String, dynamic>, d.id);
        }).toList();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.red.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'BROADCASTING LIVE RIGHT NOW',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.red,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${liveSermons.length} Live',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 115,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: liveSermons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final s = liveSermons[i];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => VideoPlayerScreen(sermon: s)),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 220,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (s.isTikTok)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('TikTok Live', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    s.language,
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    s.speaker,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.play_circle_fill, size: 18, color: Colors.red),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSermonTile(BuildContext context, Sermon sermon) {
    bool isVideo = sermon.type == SermonMediaType.video || sermon.isLiveStream;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: sermon.isLiveStream
                ? Colors.red.withOpacity(0.12)
                : isVideo
                    ? AppTheme.primaryGreen.withOpacity(0.1)
                    : AppTheme.sacredGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            sermon.isLiveStream
                ? Icons.live_tv
                : isVideo
                    ? Icons.play_circle_filled
                    : Icons.mic_external_on,
            color: sermon.isLiveStream
                ? Colors.red
                : isVideo
                    ? AppTheme.primaryGreen
                    : AppTheme.sacredGold,
            size: 30,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (sermon.isLiveStream) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
                if (sermon.isTikTok) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                    child: const Text('TikTok', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
                Expanded(
                  child: Text(
                    sermon.seriesName.isNotEmpty ? sermon.seriesName.toUpperCase() : 'SERMON',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                      letterSpacing: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  sermon.language,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              sermon.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.primaryBlue,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${sermon.speaker} • ${sermon.ministryName}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    sermon.formattedDuration,
                    style: TextStyle(
                      color: sermon.isLiveStream ? Colors.red : Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: sermon.isLiveStream ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("•", style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 8),
                  if (sermon.isPremium)
                    Text(
                      'Premium • Ksh ${sermon.price.toInt()}',
                      style: const TextStyle(
                        color: AppTheme.sacredGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Text(
                      'Free Access',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share, color: AppTheme.primaryBlue, size: 20),
              onPressed: () {
                Share.share(sermon.generateShareText());
              },
            ),
            Icon(
              sermon.isPremium ? Icons.lock : Icons.chevron_right,
              color: sermon.isPremium ? AppTheme.sacredGold : Colors.grey,
            ),
          ],
        ),
        onTap: () => _handleSermonTap(context, sermon),
      ),
    );
  }

  void _handleSermonTap(BuildContext context, Sermon sermon) {
    final mappedAudio = Song(
      id: sermon.id,
      title: sermon.title,
      artist: sermon.speaker,
      audioUrl: sermon.mediaUrl,
      publishedDate: sermon.datePreached,
    );

    if (sermon.isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioDetailScreen(
            audioId: sermon.id,
            title: sermon.title,
            speaker: sermon.speaker,
            price: sermon.price.toInt(),
            audioUrl: sermon.mediaUrl,
            songObject: mappedAudio,
          ),
        ),
      );
    } else {
      if (sermon.type == SermonMediaType.audio && !sermon.isLiveStream) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerScreen(song: mappedAudio),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(sermon: sermon),
          ),
        );
      }
    }
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: const BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.podcasts_rounded, color: AppTheme.sacredGold, size: 52),
          const SizedBox(height: 12),
          const Text(
            '"The preaching of the Word is the most important work in the world. It is the means by which God is seeking to reach those who are in darkness."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Gospel Workers, p. 147',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.sacredGold.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
