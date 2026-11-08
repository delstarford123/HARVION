import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'sda_hymn_model.dart';

class SdaHymnDetailScreen extends StatefulWidget {
  final SdaHymn hymn;

  const SdaHymnDetailScreen({super.key, required this.hymn});

  @override
  State<SdaHymnDetailScreen> createState() => _SdaHymnDetailScreenState();
}

class _SdaHymnDetailScreenState extends State<SdaHymnDetailScreen> {
  late final AudioPlayer _audioPlayer;

  bool _isLoading = true;
  bool _hasError = false;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;
  double _lyricsFontSize = 17.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initPianoAudio();
  }

  Future<void> _initPianoAudio() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Load piano accompaniment track
      final url = (widget.hymn.audioUrl != null && widget.hymn.audioUrl!.isNotEmpty)
          ? widget.hymn.audioUrl!
          : 'https://archive.org/download/sda-hymnal-instrumental/${widget.hymn.number.toString().padLeft(3, '0')}.mp3';
      await _audioPlayer.setUrl(url);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[SDA Hymnal Piano Error] Failed to load audio: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_hasError) {
      _initPianoAudio();
      return;
    }
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _replayAudio() {
    _audioPlayer.seek(Duration.zero);
    _audioPlayer.play();
  }

  void _setSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
    _audioPlayer.setSpeed(speed);
  }

  void _toggleLoop() {
    setState(() => _isLooping = !_isLooping);
    _audioPlayer.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '0:00';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Hymn #${widget.hymn.number}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Lyrics Size (A- / A+)',
            icon: const Icon(Icons.format_size_rounded),
            onPressed: () {
              setState(() {
                _lyricsFontSize = _lyricsFontSize >= 24 ? 15.0 : _lyricsFontSize + 2.0;
              });
            },
          ),
          IconButton(
            tooltip: 'Copy Lyrics',
            icon: const Icon(Icons.copy_rounded),
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: 'SDA Hymnal #${widget.hymn.number} - ${widget.hymn.title}\n\n${widget.hymn.fullLyrics}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hymn lyrics copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Share Hymn',
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              Share.share(
                '📖 SDA Hymn #${widget.hymn.number}: "${widget.hymn.title}"\n\n'
                '${widget.hymn.fullLyrics}\n\n'
                '— Sourced from HARVION SDA Ministry App & Hymnal',
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyPianoPlayerBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hymn Header Card
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // Piano Accompaniment Status Banner
            _buildPianoFeatureCard(),
            const SizedBox(height: 20),

            // Section Divider
            Row(
              children: [
                const Expanded(child: Divider(color: Colors.black12)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'SACRED LYRICS & STANZAS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Colors.black12)),
              ],
            ),
            const SizedBox(height: 16),

            // Stanzas and Chorus
            _buildLyricsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.sacredGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'HYMN #${widget.hymn.number}',
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      widget.hymn.keySignature,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.hymn.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'Serif',
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.category_outlined, color: AppTheme.sacredGold, size: 14),
              const SizedBox(width: 6),
              Text(
                widget.hymn.category,
                style: const TextStyle(
                  color: AppTheme.sacredGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPianoFeatureCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.sacredGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.piano, color: AppTheme.primaryBlue, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Piano Accompaniment (Sing Along)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Play the instrumental melody and sing along as you read the lyrics.',
                  style: TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyPianoPlayerBar() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;
        final processingState = playerState?.processingState;
        final isBuffering = processingState == ProcessingState.buffering || _isLoading;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Track Info & Quick Actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.sacredGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.piano, color: AppTheme.sacredGold, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hymn #${widget.hymn.number}: ${widget.hymn.title}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isPlaying
                                ? '🎹 Piano Playing • Sing Along'
                                : (isBuffering ? '⏳ Loading Piano Accompaniment...' : '⏸ Piano Paused • Tap Play'),
                            style: TextStyle(
                              color: isPlaying ? AppTheme.sacredGold : Colors.white70,
                              fontSize: 11,
                              fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Replay Button
                    IconButton(
                      icon: const Icon(Icons.replay, color: Colors.white70, size: 20),
                      tooltip: 'Replay from Start',
                      onPressed: _replayAudio,
                    ),
                    // Loop Toggle
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        color: _isLooping ? AppTheme.sacredGold : Colors.white38,
                        size: 20,
                      ),
                      tooltip: _isLooping ? 'Loop Active' : 'Repeat Off',
                      onPressed: _toggleLoop,
                    ),
                    // Speed Menu
                    PopupMenuButton<double>(
                      tooltip: 'Playback Pace',
                      initialValue: _playbackSpeed,
                      icon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_playbackSpeed}x',
                          style: const TextStyle(color: AppTheme.sacredGold, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 0.8, child: Text('0.8x Rehearsal Pace')),
                        const PopupMenuItem(value: 1.0, child: Text('1.0x Worship Standard')),
                        const PopupMenuItem(value: 1.2, child: Text('1.2x Brisk Pace')),
                      ],
                      onSelected: _setSpeed,
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Audio Seek Bar
                StreamBuilder<Duration>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, posSnapshot) {
                    final position = posSnapshot.data ?? Duration.zero;
                    final total = _audioPlayer.duration ?? Duration.zero;

                    final posSec = position.inMilliseconds.toDouble();
                    final totSec = total.inMilliseconds.toDouble();
                    final maxSec = totSec > 0 ? totSec : 1.0;
                    final currentVal = posSec.clamp(0.0, maxSec);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.5,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            activeTrackColor: AppTheme.sacredGold,
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                            thumbColor: AppTheme.sacredGold,
                            overlayColor: AppTheme.sacredGold.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: currentVal,
                            min: 0.0,
                            max: maxSec,
                            onChanged: (val) {
                              _audioPlayer.seek(Duration(milliseconds: val.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                              Text(
                                _formatDuration(total),
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),

                // Main Play / Pause Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.sacredGold,
                        foregroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                      icon: isBuffering
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                            )
                          : Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 24),
                      label: Text(
                        isPlaying ? 'PAUSE PIANO' : 'PLAY PIANO & SING ALONG',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLyricsContent() {
    final List<Widget> items = [];

    for (int i = 0; i < widget.hymn.stanzas.length; i++) {
      final stanzaIndex = i;

      // Stanza Card
      items.add(
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'STANZA ${stanzaIndex + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.hymn.stanzas[stanzaIndex],
                style: TextStyle(
                  fontSize: _lyricsFontSize,
                  height: 1.75,
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
      );

      items.add(const SizedBox(height: 14));

      // Chorus Card (rendered after stanza 1 or as applicable)
      if (widget.hymn.chorus.isNotEmpty && i == 0) {
        items.add(
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8EE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.sacredGold.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.sacredGold.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.sacredGold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'REFRAIN / CHORUS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Icon(Icons.music_note, color: AppTheme.sacredGold, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.hymn.chorus,
                  style: TextStyle(
                    fontSize: _lyricsFontSize,
                    height: 1.75,
                    fontFamily: 'Serif',
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        );

        items.add(const SizedBox(height: 14));
      }
    }

    return Column(children: items);
  }
}
