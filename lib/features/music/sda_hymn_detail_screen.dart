import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'sda_hymn_model.dart';
import 'data/sda_hymnal_data.dart';
import 'services/sda_hymn_audio_service.dart';

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

  // Offline Download State
  bool _isDownloaded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _checkOfflineStatus();
    _initPianoAudio();
  }

  Future<void> _checkOfflineStatus() async {
    final downloaded = await SdaHymnAudioService().isHymnDownloaded(widget.hymn.number);
    if (mounted) {
      setState(() => _isDownloaded = downloaded);
    }
  }

  Future<void> _initPianoAudio() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      }

      final audioService = SdaHymnAudioService();
      final isCached = await audioService.isHymnDownloaded(widget.hymn.number);

      if (isCached) {
        final file = await audioService.getLocalFile(widget.hymn.number);
        await _audioPlayer.setFilePath(file.path);
        if (mounted) {
          setState(() {
            _isDownloaded = true;
            _isLoading = false;
          });
        }
      } else {
        // Stream verified high-quality instrumental piano accompaniment
        final onlineUrl = audioService.getOnlineUrl(widget.hymn.number);
        await _audioPlayer.setUrl(onlineUrl);
        if (mounted) {
          setState(() {
            _isDownloaded = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('[SDA Hymnal Audio Error] Hymn #${widget.hymn.number}: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _downloadCurrentHymn() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final file = await SdaHymnAudioService().downloadHymn(
      widget.hymn.number,
      onProgress: (p) {
        if (mounted) setState(() => _downloadProgress = p);
      },
    );

    if (!mounted) return;

    if (file != null && await file.exists()) {
      setState(() {
        _isDownloaded = true;
        _isDownloading = false;
      });

      // Switch active player to local offline file
      try {
        final wasPlaying = _audioPlayer.playing;
        final currentPos = _audioPlayer.position;
        await _audioPlayer.setFilePath(file.path);
        if (currentPos > Duration.zero) {
          await _audioPlayer.seek(currentPos);
        }
        if (wasPlaying) {
          _audioPlayer.play();
        }
      } catch (e) {
        debugPrint('Seamless local switch notice: $e');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hymn #${widget.hymn.number} piano downloaded! Available 100% offline.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      setState(() => _isDownloading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed for Hymn #${widget.hymn.number}. Please check your internet connection.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteDownloadedHymn() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Offline Piano Track?'),
        content: Text('Remove downloaded audio for Hymn #${widget.hymn.number}? You can re-download anytime.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SdaHymnAudioService().deleteHymn(widget.hymn.number);
      if (mounted) {
        setState(() => _isDownloaded = false);
        _initPianoAudio();
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

  void _navigateToHymn(int targetNumber) {
    final target = SdaHymnalData.getByNumber(targetNumber);
    if (target != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SdaHymnDetailScreen(hymn: target)),
      );
    }
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '0:00';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final canGoPrev = widget.hymn.number > 1;
    final canGoNext = widget.hymn.number < 695;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          'Hymn #${widget.hymn.number}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Previous Hymn Navigation
          if (canGoPrev)
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(),
              tooltip: 'Previous Hymn (#${widget.hymn.number - 1})',
              icon: const Icon(Icons.chevron_left_rounded, size: 24),
              onPressed: () => _navigateToHymn(widget.hymn.number - 1),
            ),
          // Next Hymn Navigation
          if (canGoNext)
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(),
              tooltip: 'Next Hymn (#${widget.hymn.number + 1})',
              icon: const Icon(Icons.chevron_right_rounded, size: 24),
              onPressed: () => _navigateToHymn(widget.hymn.number + 1),
            ),
          // Lyrics Font Size Quick Button
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
            tooltip: 'Lyrics Size (A- / A+)',
            icon: const Icon(Icons.format_size_rounded, size: 20),
            onPressed: () {
              setState(() {
                _lyricsFontSize = _lyricsFontSize >= 24 ? 15.0 : _lyricsFontSize + 2.0;
              });
            },
          ),
          // Overflow Menu for Copy & Share (Prevents AppBar Overflow)
          PopupMenuButton<String>(
            tooltip: 'More Actions',
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 18, color: AppTheme.primaryBlue),
                    SizedBox(width: 10),
                    Text('Copy Lyrics'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, size: 18, color: AppTheme.primaryBlue),
                    SizedBox(width: 10),
                    Text('Share Hymn'),
                  ],
                ),
              ),
              if (_isDownloaded)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Delete Offline Piano', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                )
              else
                const PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.cloud_download_rounded, size: 18, color: Colors.green),
                      SizedBox(width: 10),
                      Text('Download Piano'),
                    ],
                  ),
                ),
            ],
            onSelected: (val) {
              if (val == 'copy') {
                Clipboard.setData(ClipboardData(
                  text: 'SDA Hymnal #${widget.hymn.number} - ${widget.hymn.title}\n\n${widget.hymn.fullLyrics}',
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hymn lyrics copied to clipboard!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (val == 'share') {
                Share.share(
                  '📖 SDA Hymn #${widget.hymn.number}: "${widget.hymn.title}"\n\n'
                  '${widget.hymn.fullLyrics}\n\n'
                  '— Sourced from HARVION SDA Ministry App & Hymnal',
                );
              } else if (val == 'download') {
                _downloadCurrentHymn();
              } else if (val == 'delete') {
                _deleteDownloadedHymn();
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: _buildStickyPianoPlayerBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hymn Header Card
            _buildHeaderCard(),
            const SizedBox(height: 14),

            // Piano Accompaniment & Offline Download Feature Card
            _buildPianoDownloadCard(),
            const SizedBox(height: 18),

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
      padding: const EdgeInsets.all(18),
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
              Flexible(
                child: Container(
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
                      fontSize: 13,
                      letterSpacing: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
              fontSize: 22,
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
              Expanded(
                child: Text(
                  widget.hymn.category,
                  style: const TextStyle(
                    color: AppTheme.sacredGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPianoDownloadCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDownloaded ? Colors.green.shade400 : AppTheme.sacredGold.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isDownloaded ? Colors.green.shade50 : AppTheme.sacredGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isDownloaded ? Icons.offline_pin_rounded : Icons.piano,
                  color: _isDownloaded ? Colors.green.shade700 : AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isDownloaded
                          ? 'Offline Piano Ready'
                          : 'Piano Accompaniment (Sing Along)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: _isDownloaded ? Colors.green.shade800 : AppTheme.primaryBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isDownloaded
                          ? 'Saved on device • Plays 100% offline without internet.'
                          : 'Pure instrumental piano chords for sing-along.',
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Download Progress Bar or Action Buttons (Safe from pixel overflow)
          if (_isDownloading)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Downloading piano audio for offline use...',
                        style: TextStyle(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(_downloadProgress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
              ],
            )
          else if (_isDownloaded)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                        const SizedBox(width: 6),
                        const Flexible(
                          child: Text(
                            'Downloaded for Offline Play',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Delete Offline Track',
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
                  onPressed: _deleteDownloadedHymn,
                ),
              ],
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.cloud_download_rounded, size: 18),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'DOWNLOAD PIANO FOR OFFLINE PLAY',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                ),
              ),
              onPressed: _downloadCurrentHymn,
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Track Info & Quick Actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _isDownloaded ? Colors.green.withValues(alpha: 0.25) : AppTheme.sacredGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        _isDownloaded ? Icons.offline_pin_rounded : Icons.piano,
                        color: _isDownloaded ? Colors.greenAccent : AppTheme.sacredGold,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hymn #${widget.hymn.number}: ${widget.hymn.title}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _hasError
                                ? '⚠️ Connection error (Tap to retry)'
                                : isPlaying
                                    ? (_isDownloaded ? '✓ Playing Offline Piano • Sing Along' : '🎹 Streaming Piano • Sing Along')
                                    : (isBuffering ? '⏳ Loading Piano Accompaniment...' : '⏸ Piano Paused • Tap Play'),
                            style: TextStyle(
                              color: _hasError ? Colors.amberAccent : (isPlaying ? AppTheme.sacredGold : Colors.white70),
                              fontSize: 10.5,
                              fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Replay Button
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.replay, color: Colors.white70, size: 18),
                      tooltip: 'Replay from Start',
                      onPressed: _replayAudio,
                    ),
                    const SizedBox(width: 6),
                    // Loop Toggle
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.repeat,
                        color: _isLooping ? AppTheme.sacredGold : Colors.white38,
                        size: 18,
                      ),
                      tooltip: _isLooping ? 'Loop Active' : 'Repeat Off',
                      onPressed: _toggleLoop,
                    ),
                    const SizedBox(width: 6),
                    // Speed Menu
                    PopupMenuButton<double>(
                      tooltip: 'Playback Pace',
                      initialValue: _playbackSpeed,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${_playbackSpeed}x',
                          style: const TextStyle(color: AppTheme.sacredGold, fontSize: 10, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 2),

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
                            trackHeight: 3.0,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6),
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
                const SizedBox(height: 4),

                // Main Play / Pause Button Row (Never overflows)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.sacredGold,
                          foregroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 3,
                        ),
                        icon: isBuffering
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                              )
                            : Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 22),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isPlaying ? 'PAUSE PIANO' : 'PLAY PIANO & SING ALONG',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, letterSpacing: 0.6),
                          ),
                        ),
                        onPressed: _togglePlayPause,
                      ),
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
          padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
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
              const SizedBox(height: 10),
              Text(
                widget.hymn.stanzas[stanzaIndex],
                style: TextStyle(
                  fontSize: _lyricsFontSize,
                  height: 1.6,
                  color: Colors.black87,
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );

      // Sacred Golden Chorus Callout
      if (widget.hymn.chorus.isNotEmpty) {
        items.add(const SizedBox(height: 12));
        items.add(
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.sacredGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.6), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.star_rounded, color: AppTheme.primaryBlue, size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'REFRAIN / CHORUS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.hymn.chorus,
                  style: TextStyle(
                    fontSize: _lyricsFontSize + 0.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    height: 1.55,
                    color: AppTheme.primaryBlue,
                    fontFamily: 'Serif',
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (i < widget.hymn.stanzas.length - 1) {
        items.add(const SizedBox(height: 14));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
  }
}
