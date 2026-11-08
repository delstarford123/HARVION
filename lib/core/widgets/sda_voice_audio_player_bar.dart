import 'package:flutter/material.dart';
import '../services/sda_voice_narration_service.dart';
import '../theme.dart';

class SdaVoiceAudioPlayerBar extends StatelessWidget {
  final VoidCallback? onClose;

  const SdaVoiceAudioPlayerBar({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SdaVoiceNarrationService.instance,
      builder: (context, _) {
        final tts = SdaVoiceNarrationService.instance;
        if (!tts.isPlaying && !tts.isPaused) {
          return const SizedBox.shrink();
        }

        final isMale = tts.gender == SdaVoiceGender.male;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.sacredGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.record_voice_over, color: AppTheme.sacredGold, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tts.currentTitle.isNotEmpty ? tts.currentTitle : 'Voice Version (Godly Narration)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          tts.isPlaying
                              ? (isMale ? '🔴 Male Minister Voice' : '🔴 Gentle Sister Voice')
                              : '⏸ Narration paused',
                          style: TextStyle(
                            color: tts.isPlaying ? Colors.yellow.shade200 : Colors.grey.shade300,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Male / Female Voice Switcher Pill
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      final newGender = isMale ? SdaVoiceGender.female : SdaVoiceGender.male;
                      tts.setVoiceGender(newGender);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isMale ? Icons.man : Icons.woman, size: 14, color: AppTheme.sacredGold),
                          const SizedBox(width: 2),
                          Text(
                            isMale ? 'Male' : 'Female',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Speed button
                  PopupMenuButton<double>(
                    tooltip: 'Speaking Pace',
                    initialValue: tts.speechRate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(tts.speechRate * 2.2).toStringAsFixed(1)}x',
                        style: const TextStyle(color: AppTheme.sacredGold, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 0.35, child: Text('0.8x Solemn & Slow')),
                      const PopupMenuItem(value: 0.44, child: Text('1.0x Reverent (Default)')),
                      const PopupMenuItem(value: 0.52, child: Text('1.2x Normal')),
                      const PopupMenuItem(value: 0.60, child: Text('1.4x Fast')),
                    ],
                    onSelected: (rate) => tts.setPacing(rate: rate),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      tts.stop();
                      onClose?.call();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    iconSize: 22,
                    onPressed: tts.previous,
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      if (tts.isPlaying) {
                        tts.pause();
                      } else {
                        tts.resume();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.sacredGold,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tts.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    iconSize: 22,
                    onPressed: tts.next,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
