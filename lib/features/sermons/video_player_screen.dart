import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import 'sermon_model.dart';
import 'widgets/livestream_embed_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Sermon sermon;

  const VideoPlayerScreen({super.key, required this.sermon});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool _hasError = false;
  bool _isInitializing = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // If YouTube, Google Drive, or TikTok, we do not require Chewie networkUrl parsing
    if (widget.sermon.isYouTube || widget.sermon.isGoogleDrive || widget.sermon.isTikTok) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = false;
        });
      }
      return;
    }

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.sermon.mediaUrl));
      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio > 0
            ? _videoPlayerController!.value.aspectRatio
            : 16 / 9,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.sacredGold,
          handleColor: AppTheme.sacredGold,
          backgroundColor: Colors.white.withOpacity(0.2),
          bufferedColor: Colors.white.withOpacity(0.5),
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint("Video Load Error: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _openExternalVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _postLiveComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    await FirebaseFirestore.instance
        .collection('livestreams')
        .doc(widget.sermon.id)
        .collection('comments')
        .add({
      'authorName': 'Viewer / Believer',
      'text': text,
      'postedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.sermon.isLiveStream ? "🔴 LIVE BROADCAST" : "Now Playing",
          style: TextStyle(
            fontSize: 14,
            fontWeight: widget.sermon.isLiveStream ? FontWeight.bold : FontWeight.normal,
            color: widget.sermon.isLiveStream ? Colors.redAccent : Colors.white70,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Video / Stream Screen (16:9 box)
            Container(
              color: Colors.black,
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(
                  child: _buildVideoContent(),
                ),
              ),
            ),

            // Video Details and Live Chat
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges row (wrapped to prevent RenderFlex overflow)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (widget.sermon.isLiveStream)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(radius: 3, backgroundColor: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'LIVE NOW',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.sermon.seriesName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        if (widget.sermon.isYouTube)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: const Text(
                              'YouTube Source',
                              style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (widget.sermon.isTikTok)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.videocam, color: Colors.white, size: 10),
                                SizedBox(width: 4),
                                Text(
                                  'TikTok Live',
                                  style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: Text(
                            widget.sermon.language,
                            style: TextStyle(fontSize: 10, color: Colors.indigo.shade800, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      widget.sermon.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Speaker & Date Info
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.sacredGold,
                          child: Icon(Icons.person, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.sermon.speaker,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text("•", style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(widget.sermon.datePreached),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                          icon: Icons.open_in_new,
                          label: widget.sermon.isYouTube ? "Open YouTube" : "Open Link",
                          onTap: () => _openExternalVideo(widget.sermon.mediaUrl),
                        ),
                        _buildActionButton(
                          icon: Icons.share_outlined,
                          label: "Share",
                          onTap: () => Share.share(
                            "🕊️ *${widget.sermon.title}*\n"
                            "Speaker: ${widget.sermon.speaker}\n"
                            "Watch live or replay on Harvion:\n${widget.sermon.mediaUrl}",
                          ),
                        ),
                        _buildActionButton(
                          icon: Icons.bookmark_border,
                          label: "Save",
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved to your spiritual library!')),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    // Description
                    const Text('About this Session / Teaching', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue)),
                    const SizedBox(height: 6),
                    Text(
                      widget.sermon.description.isNotEmpty
                          ? widget.sermon.description
                          : "No description provided for this teaching.",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Live Comments & Prayer Intercession Stream
                    const Text('Live Stream Chat & Prayer Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue)),
                    const SizedBox(height: 8),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('livestreams')
                            .doc(widget.sermon.id)
                            .collection('comments')
                            .orderBy('postedAt', descending: true)
                            .limit(20)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'Be the first to post a comment or prayer request!',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            );
                          }
                          final docs = snapshot.data!.docs;
                          return ListView.builder(
                            reverse: true,
                            itemCount: docs.length,
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, i) {
                              final data = docs[i].data() as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    children: [
                                      TextSpan(
                                        text: '${data['authorName'] ?? 'Believer'}: ',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                      ),
                                      TextSpan(text: data['text'] ?? ''),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Live Comment Input Box
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Share prayer request or comment...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppTheme.primaryGreen),
                          onPressed: _postLiveComment,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (widget.sermon.isYouTube || widget.sermon.videoSourceType.toLowerCase() == 'youtube') {
      return LivestreamEmbedPlayer(
        mediaUrl: widget.sermon.mediaUrl,
        platform: 'youtube',
        title: widget.sermon.title,
      );
    }

    if (widget.sermon.isTikTok || widget.sermon.videoSourceType.toLowerCase() == 'tiktok') {
      final tikTokUrl = widget.sermon.tikTokLiveUrl.isNotEmpty
          ? widget.sermon.tikTokLiveUrl
          : widget.sermon.mediaUrl;
      return LivestreamEmbedPlayer(
        mediaUrl: tikTokUrl,
        platform: 'tiktok',
        title: widget.sermon.title,
      );
    }

    if (widget.sermon.isGoogleDrive) {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_download, color: Colors.blueAccent, size: 48),
              const SizedBox(height: 10),
              const Text('Google Drive Video Stream', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                icon: const Icon(Icons.play_arrow),
                label: const Text('OPEN GOOGLE DRIVE STREAM'),
                onPressed: () => _openExternalVideo(widget.sermon.mediaUrl),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }
    if (_isInitializing) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.sacredGold),
          SizedBox(height: 16),
          Text('Loading Video...', style: TextStyle(color: Colors.white70)),
        ],
      );
    }
    if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    }
    return _buildErrorState();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppTheme.primaryBlue,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.play_circle_outline, color: AppTheme.sacredGold, size: 48),
        const SizedBox(height: 10),
        const Text('Direct Playback Preview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
          icon: const Icon(Icons.open_in_browser),
          label: const Text('OPEN STREAM LINK'),
          onPressed: () => _openExternalVideo(widget.sermon.mediaUrl),
        ),
      ],
    );
  }
}
