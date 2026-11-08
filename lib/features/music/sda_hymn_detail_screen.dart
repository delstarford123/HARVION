import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../../core/services/sda_voice_narration_service.dart';
import '../../core/widgets/sda_voice_audio_player_bar.dart';
import 'sda_hymn_model.dart';

class SdaHymnDetailScreen extends StatefulWidget {
  final SdaHymn hymn;

  const SdaHymnDetailScreen({super.key, required this.hymn});

  @override
  State<SdaHymnDetailScreen> createState() => _SdaHymnDetailScreenState();
}

class _SdaHymnDetailScreenState extends State<SdaHymnDetailScreen> {
  int _activeSegmentIndex = -1;
  late final List<String> _narrationSegments;

  @override
  void initState() {
    super.initState();
    _prepareNarrationSegments();
  }

  void _prepareNarrationSegments() {
    _narrationSegments = [];
    for (int i = 0; i < widget.hymn.stanzas.length; i++) {
      _narrationSegments.add('Stanza ${i + 1}. ${widget.hymn.stanzas[i]}');
      if (widget.hymn.chorus.isNotEmpty) {
        _narrationSegments.add('Chorus. ${widget.hymn.chorus}');
      }
    }
  }

  void _startHymnNarration({int startIndex = 0}) {
    SdaVoiceNarrationService.instance.speakQueue(
      segments: _narrationSegments,
      title: 'Hymn ${widget.hymn.number}: ${widget.hymn.title}',
      startIndex: startIndex,
      onIndexChanged: (idx) {
        if (mounted) setState(() => _activeSegmentIndex = idx);
      },
      onComplete: () {
        if (mounted) setState(() => _activeSegmentIndex = -1);
      },
    );
  }

  void _stopHymnNarration() {
    SdaVoiceNarrationService.instance.stop();
    setState(() => _activeSegmentIndex = -1);
  }

  @override
  void dispose() {
    // Only stop if currently narrating this hymn
    if (SdaVoiceNarrationService.instance.currentTitle.contains('Hymn ${widget.hymn.number}')) {
      SdaVoiceNarrationService.instance.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SdaVoiceNarrationService.instance,
      builder: (context, _) {
        final isVoiceActive = SdaVoiceNarrationService.instance.isPlaying ||
            SdaVoiceNarrationService.instance.isPaused;

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
          bottomNavigationBar: isVoiceActive
              ? SdaVoiceAudioPlayerBar(
                  onClose: _stopHymnNarration,
                )
              : null,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hymn Header Card
                _buildHeaderCard(isVoiceActive),
                const SizedBox(height: 20),

                // Sing / Voice Action Banner
                _buildVoiceActionBanner(isVoiceActive),
                const SizedBox(height: 24),

                // Section Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.black12)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'HYMN LYRICS & STANZAS',
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
      },
    );
  }

  Widget _buildHeaderCard(bool isVoiceActive) {
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

  Widget _buildVoiceActionBanner(bool isVoiceActive) {
    final isPlaying = SdaVoiceNarrationService.instance.isPlaying;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVoiceActive ? AppTheme.sacredGold : Colors.black12,
          width: isVoiceActive ? 2 : 1,
        ),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: (isPlaying ? AppTheme.sacredGold : AppTheme.primaryBlue).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.record_voice_over : Icons.volume_up_rounded,
              color: isPlaying ? AppTheme.sacredGold : AppTheme.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVoiceActive
                      ? (isPlaying ? 'Singing / Speaking Hymn...' : 'Voice Paused')
                      : 'Adventist Voice Version',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isVoiceActive
                      ? 'Listen to solemn narration & sing along'
                      : 'Hear stanzas read with godly reverence',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isPlaying ? Colors.orange.shade800 : AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 18),
            label: Text(isPlaying ? 'Pause' : (isVoiceActive ? 'Resume' : 'Listen')),
            onPressed: () {
              if (isPlaying) {
                SdaVoiceNarrationService.instance.pause();
              } else if (SdaVoiceNarrationService.instance.isPaused) {
                SdaVoiceNarrationService.instance.resume();
              } else {
                _startHymnNarration();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsContent() {
    int segmentCounter = 0;
    final List<Widget> items = [];

    for (int i = 0; i < widget.hymn.stanzas.length; i++) {
      final stanzaIndex = i;
      final currentSegmentIndex = segmentCounter++;
      final isThisStanzaSpeaking = _activeSegmentIndex == currentSegmentIndex;

      // Stanza Card
      items.add(
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _startHymnNarration(startIndex: currentSegmentIndex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isThisStanzaSpeaking
                  ? AppTheme.sacredGold.withValues(alpha: 0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isThisStanzaSpeaking
                    ? AppTheme.sacredGold
                    : Colors.black.withValues(alpha: 0.08),
                width: isThisStanzaSpeaking ? 2 : 1,
              ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isThisStanzaSpeaking
                            ? AppTheme.sacredGold
                            : AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'STANZA ${stanzaIndex + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isThisStanzaSpeaking ? Colors.white : AppTheme.primaryBlue,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    if (isThisStanzaSpeaking)
                      const Row(
                        children: [
                          Icon(Icons.volume_up, color: AppTheme.sacredGold, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Speaking',
                            style: TextStyle(
                              color: AppTheme.sacredGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.play_circle_outline, size: 20, color: Colors.grey),
                        onPressed: () => _startHymnNarration(startIndex: currentSegmentIndex),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.hymn.stanzas[stanzaIndex],
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.65,
                    fontFamily: 'Serif',
                    fontWeight: isThisStanzaSpeaking ? FontWeight.w600 : FontWeight.w400,
                    color: isThisStanzaSpeaking ? AppTheme.primaryBlue : Colors.grey.shade900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      items.add(const SizedBox(height: 14));

      // Chorus Card (if exists)
      if (widget.hymn.chorus.isNotEmpty) {
        final chorusSegmentIndex = segmentCounter++;
        final isThisChorusSpeaking = _activeSegmentIndex == chorusSegmentIndex;

        items.add(
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _startHymnNarration(startIndex: chorusSegmentIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isThisChorusSpeaking
                    ? AppTheme.sacredGold.withValues(alpha: 0.2)
                    : const Color(0xFFFBF8EE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isThisChorusSpeaking
                      ? AppTheme.sacredGold
                      : AppTheme.sacredGold.withValues(alpha: 0.4),
                  width: isThisChorusSpeaking ? 2 : 1,
                ),
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
                          'CHORUS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      if (isThisChorusSpeaking)
                        const Row(
                          children: [
                            Icon(Icons.volume_up, color: AppTheme.sacredGold, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Speaking',
                              style: TextStyle(
                                color: AppTheme.sacredGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.hymn.chorus,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.65,
                      fontFamily: 'Serif',
                      fontStyle: FontStyle.italic,
                      fontWeight: isThisChorusSpeaking ? FontWeight.w700 : FontWeight.w500,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        items.add(const SizedBox(height: 14));
      }
    }

    return Column(children: items);
  }
}
