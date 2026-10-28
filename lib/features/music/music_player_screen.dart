import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart'; // 🚀 Added for the Share Engine
import '../../core/theme.dart';
import 'song_model.dart'; // Note: You might rename this to sermon_model.dart later!

class MusicPlayerScreen extends StatefulWidget {
  final Song song;

  const MusicPlayerScreen({super.key, required this.song});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // Load the audio from the network URL
      await _audioPlayer.setUrl(widget.song.audioUrl);
      setState(() {
        _isLoading = false;
      });
      // Auto-play when ready
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Error loading audio: $e");
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading audio. Please check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer
        .dispose(); // Always clean up resources to prevent memory leaks!
    super.dispose();
  }

  // Helper method to format the duration into mm:ss
  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 32, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 🚀 THE SHARE BUTTON
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share Audio',
            onPressed: () {
              // Assuming your Song/Sermon model has a generateShareText() method like the Book model!
              final String shareText =
                  "🎧 *VINE Audio: ${widget.song.title}* 🎧\n\n"
                  "Speaker: ${widget.song.artist}\n\n"
                  "Listen to the full audio on the VINE App today!";
              Share.share(shareText);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album Art Placeholder
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.audiotrack, // Changed to audiotrack for sermons/lectures
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),

            // Song/Sermon Info
            Text(
              widget.song.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.song.artist,
              style: const TextStyle(fontSize: 16, color: AppTheme.sacredGold),
            ),
            const SizedBox(height: 32),

            // 🚀 THE TIMELINE SLIDER
            StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = _audioPlayer.duration ?? Duration.zero;

                // Prevent slider errors if duration isn't loaded yet
                double sliderValue = position.inSeconds.toDouble();
                double sliderMax = duration.inSeconds.toDouble();
                if (sliderValue > sliderMax || sliderMax == 0) {
                  sliderValue = 0.0;
                  sliderMax = 1.0;
                }

                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8.0),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 16.0),
                      ),
                      child: Slider(
                        activeColor: AppTheme.sacredGold,
                        inactiveColor: Colors.white.withOpacity(0.3),
                        value: sliderValue,
                        max: sliderMax,
                        onChanged: (value) {
                          _audioPlayer.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                    // The Timestamps (e.g., 01:23 / 45:00)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // 🚀 PLAYBACK CONTROLS
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(24.0),
                    child:
                        CircularProgressIndicator(color: AppTheme.sacredGold),
                  )
                : StreamBuilder<PlayerState>(
                    stream: _audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState;
                      final playing = playerState?.playing;

                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(
                              color: AppTheme.sacredGold),
                        );
                      } else if (playing != true) {
                        return IconButton(
                          icon: const Icon(Icons.play_circle_fill),
                          iconSize: 80.0,
                          color: AppTheme.sacredGold,
                          onPressed: _audioPlayer.play,
                        );
                      } else if (processingState != ProcessingState.completed) {
                        return IconButton(
                          icon: const Icon(Icons.pause_circle_filled),
                          iconSize: 80.0,
                          color: AppTheme.sacredGold,
                          onPressed: _audioPlayer.pause,
                        );
                      } else {
                        return IconButton(
                          icon: const Icon(Icons.replay_circle_filled),
                          iconSize: 80.0,
                          color: AppTheme.sacredGold,
                          onPressed: () => _audioPlayer.seek(Duration.zero),
                        );
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
