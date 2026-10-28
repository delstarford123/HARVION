import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../sermons/sermons_screen.dart';
import '../music/music_screen.dart';

class MediaLibraryScreen extends StatefulWidget {
  const MediaLibraryScreen({super.key});

  @override
  State<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends State<MediaLibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _mediaTabs = [
    'All Media',
    'Audio Sermons',
    'SDA Choir Hymns',
    'Health Talks',
    'Prophecy Seminars',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _mediaTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Sermon & Media Library', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.sacredGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _mediaTabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Quick navigation pill buttons to existing dedicated players
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.podcasts, size: 18, color: AppTheme.primaryBlue),
                    label: const Text('All Sermons', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SermonsScreen()));
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.music_note, size: 18, color: AppTheme.primaryGreen),
                    label: const Text('Choir Music', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicScreen()));
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMediaList(_getAllMediaItems()),
                _buildMediaList(_getAllMediaItems().where((m) => m['type'] == 'Audio Sermon').toList()),
                _buildMediaList(_getAllMediaItems().where((m) => m['type'] == 'Choir Hymn').toList()),
                _buildMediaList(_getAllMediaItems().where((m) => m['type'] == 'Health Talk').toList()),
                _buildMediaList(_getAllMediaItems().where((m) => m['type'] == 'Prophecy Series').toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaList(List<Map<String, dynamic>> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isVideo = item['isVideo'] as bool;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: isVideo
                  ? Colors.red.withOpacity(0.12)
                  : AppTheme.primaryGreen.withOpacity(0.12),
              child: Icon(
                isVideo ? Icons.play_arrow : Icons.headphones,
                color: isVideo ? Colors.red : AppTheme.primaryGreen,
              ),
            ),
            title: Text(
              item['title'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${item['speaker']} • ${item['duration']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['type'],
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_fill, size: 36, color: AppTheme.primaryBlue),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Streaming "${item['title']}"...'),
                    backgroundColor: AppTheme.primaryBlue,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getAllMediaItems() {
    return [
      {
        'title': 'The Three Angels of Revelation 14',
        'speaker': 'Alfredo Onuko',
        'duration': '48 mins',
        'type': 'Audio Sermon',
        'isVideo': false,
      },
      {
        'title': 'The Great Physician & Lifestyle Remedies',
        'speaker': 'Medical Missionary Team',
        'duration': '35 mins',
        'type': 'Health Talk',
        'isVideo': true,
      },
      {
        'title': 'Crown Him With Many Crowns (Acapella)',
        'speaker': 'Nairobi Central SDA Choir',
        'duration': '4 mins 20s',
        'type': 'Choir Hymn',
        'isVideo': false,
      },
      {
        'title': 'Daniel 2: The Statue and the Stone',
        'speaker': 'Prophecy Seminar Series',
        'duration': '1 hour 12 mins',
        'type': 'Prophecy Series',
        'isVideo': true,
      },
      {
        'title': 'Country Living: The Call of the Hour',
        'speaker': 'Alfredo Onuko',
        'duration': '52 mins',
        'type': 'Audio Sermon',
        'isVideo': false,
      },
      {
        'title': 'Nearer, My God, to Thee (SDA Hymnal #473)',
        'speaker': 'Maxwell Choral Ensemble',
        'duration': '5 mins 10s',
        'type': 'Choir Hymn',
        'isVideo': false,
      },
      {
        'title': 'Reversing Hypertension with the 8 Laws',
        'speaker': 'Adventist Lifestyle Institute',
        'duration': '42 mins',
        'type': 'Health Talk',
        'isVideo': false,
      },
    ];
  }
}

