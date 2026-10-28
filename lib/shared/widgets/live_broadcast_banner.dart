import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/sermons/sermon_model.dart';
import '../../features/sermons/video_player_screen.dart';

class LiveBroadcastBanner extends StatefulWidget {
  const LiveBroadcastBanner({super.key});

  @override
  State<LiveBroadcastBanner> createState() => _LiveBroadcastBannerState();
}

class _LiveBroadcastBannerState extends State<LiveBroadcastBanner> {
  String? _dismissedSermonId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('live_announcements')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        final sermonId = doc.id;

        if (_dismissedSermonId == sermonId) {
          return const SizedBox.shrink();
        }

        final title = data['title'] as String? ?? 'Special Live Ministry Broadcast';
        final speaker = data['speaker'] as String? ?? 'Pastor / Speaker';
        final language = data['language'] as String? ?? 'English';
        final platform = data['platform'] as String? ?? 'live';
        final mediaUrl = data['mediaUrl'] as String? ?? '';

        return Material(
          color: Colors.red.shade700,
          child: InkWell(
            onTap: () {
              final sermon = Sermon(
                id: sermonId,
                title: title,
                speaker: speaker,
                description: 'Live broadcast in $language on Harvion SDA Platform.',
                mediaUrl: mediaUrl,
                type: SermonMediaType.video,
                datePreached: DateTime.now(),
                duration: Duration.zero,
                isLiveStream: true,
                language: language,
                videoSourceType: platform,
              );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideoPlayerScreen(sermon: sermon)),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.podcasts, color: Colors.red, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: '🔴 LIVE NOW: ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                          ),
                          TextSpan(
                            text: '$speaker - "$title" ($language) ',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const TextSpan(
                            text: '• JOIN NOW',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD54F), fontSize: 12),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Dismiss alert',
                    onPressed: () {
                      setState(() {
                        _dismissedSermonId = sermonId;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
