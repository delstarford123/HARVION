import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme.dart';

class InlineAudioPlayerWidget extends StatefulWidget {
  final String title;
  final String speaker;
  final String audioUrl; // 🚀 We pass the URL directly now!

  const InlineAudioPlayerWidget({
    super.key,
    required this.title,
    required this.speaker,
    required this.audioUrl,
  });

  @override
  State<InlineAudioPlayerWidget> createState() =>
      _InlineAudioPlayerWidgetState();
}

class _InlineAudioPlayerWidgetState extends State<InlineAudioPlayerWidget> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // Pre-load the audio so it's ready to play instantly when the user taps it
      await _audioPlayer.setUrl(widget.audioUrl);
    } catch (e) {
      debugPrint("Inline Audio Load Error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Prevent memory leaks when navigating away
    super.dispose();
  }

  // Helper to format 01:23 time
  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Keeps the widget tightly wrapped
        children: [
          // 1. Top Row: Title, Speaker, and Volume Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic,
                    color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.primaryBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.speaker,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.volume_up_rounded, size: 18, color: Colors.grey),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Bottom Row: Play Button & Progress Slider
          Row(
            children: [
              // 🚀 Dynamic Play/Pause Button
              StreamBuilder<PlayerState>(
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;

                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppTheme.sacredGold,
                        ),
                      ),
                    );
                  } else if (playing != true) {
                    return IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.play_circle_fill,
                          size: 40, color: AppTheme.sacredGold),
                      onPressed: _audioPlayer.play,
                    );
                  } else if (processingState != ProcessingState.completed) {
                    return IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.pause_circle_filled,
                          size: 40, color: AppTheme.sacredGold),
                      onPressed: _audioPlayer.pause,
                    );
                  } else {
                    return IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.replay_circle_filled,
                          size: 40, color: AppTheme.sacredGold),
                      onPressed: () => _audioPlayer.seek(Duration.zero),
                    );
                  }
                },
              ),

              const SizedBox(width: 8),

              // 🚀 Dynamic Timeline Slider
              Expanded(
                child: StreamBuilder<Duration>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = _audioPlayer.duration ?? Duration.zero;

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
                            trackHeight: 3.0,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6.0),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12.0),
                          ),
                          child: Slider(
                            activeColor: AppTheme.primaryGreen,
                            inactiveColor: Colors.grey.shade300,
                            value: sliderValue,
                            max: sliderMax,
                            onChanged: (value) {
                              _audioPlayer
                                  .seek(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                        // Timestamps
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 10),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
