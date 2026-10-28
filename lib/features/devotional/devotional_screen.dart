import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'models/devotional_model.dart';

class DevotionalScreen extends StatefulWidget {
  const DevotionalScreen({super.key});

  @override
  State<DevotionalScreen> createState() => _DevotionalScreenState();
}

class _DevotionalScreenState extends State<DevotionalScreen> {
  late List<DailyDevotional> _devotionals;
  int _currentIndex = 0;
  double _fontSize = 16.0;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _devotionals = DailyDevotional.getRecentDevotionals();
  }

  void _shareDevotional(DailyDevotional dev) {
    Share.share(
      "🌅 *DAILY DEVOTIONAL: ${dev.title}* 🌅\n\n"
      "📖 *${dev.scriptureReference}*\n"
      "\"${dev.scriptureText}\"\n\n"
      "${dev.commentary}\n\n"
      "✍️ *${dev.author}*\n\n"
      "🙏 *Prayer Thought:*\n${dev.prayerThought}\n\n"
      "🌱 Read daily on the Harvion SDA App!",
    );
  }

  @override
  Widget build(BuildContext context) {
    final dev = _devotionals[_currentIndex];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Daily Morning Watch', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Text Size',
            icon: const Icon(Icons.format_size),
            onPressed: () {
              setState(() {
                if (_fontSize >= 20.0) {
                  _fontSize = 14.0;
                } else {
                  _fontSize += 2.0;
                }
              });
            },
          ),
          IconButton(
            tooltip: 'Share Devotional',
            icon: const Icon(Icons.share),
            onPressed: () => _shareDevotional(dev),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Switcher Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentIndex < _devotionals.length - 1
                        ? () => setState(() => _currentIndex += 1)
                        : null,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(dev.date),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentIndex > 0
                        ? () => setState(() => _currentIndex -= 1)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Devotional Title Card
            Text(
              dev.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dev.author,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Audio Listen & Offline Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlayingAudio ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: AppTheme.primaryGreen,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() => _isPlayingAudio = !_isPlayingAudio);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isPlayingAudio
                              ? 'Playing Morning Devotional Audio narration...'
                              : 'Audio paused.'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPlayingAudio ? 'Listening: Audio Narration' : 'Listen to Morning Audio',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGreen),
                        ),
                        const Text(
                          'Available offline in your local cache',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Scripture Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7), // Warm parchment
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.sacredGold.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dev.scriptureReference,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: AppTheme.primaryBlue),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '${dev.scriptureReference}: "${dev.scriptureText}"'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Scripture verse copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '"${dev.scriptureText}"',
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Commentary / Reading
            const Text(
              'Spiritual Reflection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 12),
            Text(
              dev.commentary,
              style: TextStyle(
                fontSize: _fontSize,
                height: 1.7,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Prayer Thought Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.volunteer_activism, color: AppTheme.primaryGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Prayer Thought for Today',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dev.prayerThought,
                    style: TextStyle(
                      fontSize: _fontSize - 1,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today\'s Reading';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

