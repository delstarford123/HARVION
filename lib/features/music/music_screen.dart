import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'song_model.dart';
import 'music_player_screen.dart';
import 'audio_detail_screen.dart';
import 'sda_hymn_model.dart';
import 'data/sda_hymnal_data.dart';
import 'sda_hymn_detail_screen.dart';
import 'services/sda_hymn_audio_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Hymnal Search & Filter
  final TextEditingController _hymnSearchController = TextEditingController();
  String _hymnSearchQuery = '';
  String _selectedCategory = 'All';
  Set<int> _downloadedHymns = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDownloadedHymns();
  }

  Future<void> _loadDownloadedHymns() async {
    final downloaded = await SdaHymnAudioService().getDownloadedHymnNumbers();
    if (mounted) {
      setState(() => _downloadedHymns = downloaded);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hymnSearchController.dispose();
    super.dispose();
  }

  // Categories available in hymnal
  List<String> get _categories {
    final set = <String>{'All'};
    for (final h in SdaHymnalData.hymns) {
      set.add(h.category);
    }
    return set.toList();
  }

  List<SdaHymn> get _filteredHymns {
    return SdaHymnalData.hymns.where((hymn) {
      final matchesCategory = _selectedCategory == 'All' || hymn.category == _selectedCategory;
      if (!matchesCategory) return false;

      if (_hymnSearchQuery.isEmpty) return true;
      final q = _hymnSearchQuery.toLowerCase();
      final numStr = hymn.number.toString();
      final title = hymn.title.toLowerCase();
      final lyrics = hymn.fullLyrics.toLowerCase();

      return numStr.contains(q) || title.contains(q) || lyrics.contains(q);
    }).toList();
  }

  // ==========================================
  // 🗑️ DELETE AUDIO TRACK
  // ==========================================
  Future<void> _deleteAudioTrack(String trackId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Audio Track?'),
        content: Text('Are you sure you want to permanently remove "$title" from the library?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Track'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('sermons').doc(trackId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed "$title" from audio library.'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete track: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ==========================================
  // ➕ POST / ADD NEW AUDIO TRACK MODAL
  // ==========================================
  void _showAddAudioModal() {
    final titleCtrl = TextEditingController();
    final artistCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '0');
    String selectedCategory = 'Sacred Choir';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.library_music, color: AppTheme.primaryBlue),
                        SizedBox(width: 8),
                        Text(
                          'Post Audio / Sermon',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Audio Title *',
                    hintText: 'e.g. Abide With Me - Male Chorale',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: artistCtrl,
                  decoration: InputDecoration(
                    labelText: 'Artist / Choir / Preacher *',
                    hintText: 'e.g. HARVION Sacred Choir',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: InputDecoration(
                    labelText: 'Audio MP3 URL *',
                    hintText: 'https://archive.org/... or direct mp3',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Sacred Choir', child: Text('Sacred Choir')),
                          DropdownMenuItem(value: 'Sermon', child: Text('Sermon')),
                          DropdownMenuItem(value: 'SDA Hymn', child: Text('SDA Hymn')),
                          DropdownMenuItem(value: 'Devotional', child: Text('Devotional')),
                          DropdownMenuItem(value: 'Health Lecture', child: Text('Health Lecture')),
                          DropdownMenuItem(value: 'Youth Worship', child: Text('Youth Worship')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedCategory = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price (Ksh)',
                          hintText: '0 = Free',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    isSubmitting ? 'Uploading to Library...' : 'Publish Audio Track',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final title = titleCtrl.text.trim();
                          final artist = artistCtrl.text.trim();
                          final url = urlCtrl.text.trim();
                          final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;

                          if (title.isEmpty || artist.isEmpty || url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in Title, Artist, and Audio URL.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isSubmitting = true);

                          try {
                            await FirebaseFirestore.instance.collection('sermons').add({
                              'title': title,
                              'speaker': artist,
                              'audioUrl': url,
                              'category': selectedCategory,
                              'price': price,
                              'publishedDate': FieldValue.serverTimestamp(),
                            });

                            if (mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Audio track "$title" published successfully!'),
                                  backgroundColor: AppTheme.primaryGreen,
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to publish audio: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 🌱 SEED SAMPLE SACRED TRACKS
  // ==========================================
  Future<void> _seedSampleTracks() async {
    final samples = [
      {
        'title': 'Great Is Thy Faithfulness',
        'speaker': 'HARVION Adventist Symphony Choir',
        'audioUrl': 'https://archive.org/download/sda-hymnal-instrumental/100_Great_Is_Thy_Faithfulness.mp3',
        'category': 'Sacred Choir',
        'price': 0.0,
      },
      {
        'title': 'The Three Angels\' Messages Explained',
        'speaker': 'Pastor H.M.S. Richards',
        'audioUrl': 'https://archive.org/download/sda-hymnal-instrumental/001_Praise_to_the_Lord.mp3',
        'category': 'Sermon',
        'price': 0.0,
      },
      {
        'title': 'We Have This Hope (Advent Hymn)',
        'speaker': 'SDA General Conference Session Choir',
        'audioUrl': 'https://archive.org/download/sda-hymnal-instrumental/214_We_Have_This_Hope.mp3',
        'category': 'SDA Hymn',
        'price': 0.0,
      },
      {
        'title': 'Holy Sabbath, Day of Rest',
        'speaker': 'East Africa Heritage Chorale',
        'audioUrl': 'https://archive.org/download/sda-hymnal-instrumental/381_Holy_Sabbath_Day_of_Rest.mp3',
        'category': 'Sacred Choir',
        'price': 0.0,
      },
      {
        'title': 'God\'s Love for Man (Steps to Christ Ch. 1)',
        'speaker': 'HARVION Audio Ministry',
        'audioUrl': 'https://archive.org/download/sda-hymnal-instrumental/108_Amazing_Grace.mp3',
        'category': 'Devotional',
        'price': 0.0,
      },
    ];

    try {
      final batch = FirebaseFirestore.instance.batch();
      final coll = FirebaseFirestore.instance.collection('sermons');
      for (final s in samples) {
        final doc = coll.doc();
        batch.set(doc, {
          ...s,
          'publishedDate': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample sacred audio tracks added to library!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to seed audio: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'SDA Music & Audio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Post New Audio Track',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddAudioModal,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.sacredGold,
          indicatorWeight: 3,
          labelColor: AppTheme.sacredGold,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: 'Official SDA Hymnal'),
            Tab(icon: Icon(Icons.graphic_eq), text: 'Sacred Audio & Sermons'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.sacredGold,
        icon: const Icon(Icons.cloud_upload_outlined),
        label: const Text('Post Audio', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showAddAudioModal,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSdaHymnalTab(),
          _buildAudioSermonsTab(),
        ],
      ),
    );
  }

  // ==========================================
  // 📖 TAB 1: OFFICIAL SDA HYMNAL
  // ==========================================
  Widget _buildSdaHymnalTab() {
    final hymns = _filteredHymns;

    return Column(
      children: [
        // Search & Category Bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _hymnSearchController,
                decoration: InputDecoration(
                  hintText: 'Search hymn # (e.g. 100) or title/lyrics...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                  suffixIcon: _hymnSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _hymnSearchController.clear();
                            setState(() => _hymnSearchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => setState(() => _hymnSearchQuery = val.trim()),
              ),
              const SizedBox(height: 10),
              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryBlue,
                        backgroundColor: AppTheme.backgroundLight,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.primaryBlue,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Hymn Count Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${hymns.length} Hymns',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.piano, color: AppTheme.primaryBlue, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Piano Accompaniment (Sing Along)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Hymn Cards List
        Expanded(
          child: hymns.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No hymn found matching "$_hymnSearchQuery"',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: hymns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final hymn = hymns[index];
                    return _buildHymnCard(hymn);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHymnCard(SdaHymn hymn) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SdaHymnDetailScreen(hymn: hymn)),
            );
            _loadDownloadedHymns();
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Hymn Number Badge
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'HYMN',
                        style: TextStyle(
                          color: AppTheme.sacredGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '#${hymn.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hymn.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.sacredGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hymn.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '• ${hymn.stanzas.length} Stanzas',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          if (_downloadedHymns.contains(hymn.number)) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green.shade300, width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, size: 10, color: Colors.green.shade700),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Offline',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Piano Accompaniment (Sing Along) Button
                IconButton(
                  tooltip: _downloadedHymns.contains(hymn.number)
                      ? 'Play Offline Piano Accompaniment'
                      : 'Play Piano Accompaniment & Sing Along',
                  icon: Icon(
                    _downloadedHymns.contains(hymn.number) ? Icons.offline_pin_rounded : Icons.piano,
                    color: _downloadedHymns.contains(hymn.number) ? Colors.green.shade700 : AppTheme.primaryBlue,
                    size: 26,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SdaHymnDetailScreen(hymn: hymn)),
                    );
                    _loadDownloadedHymns();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 🎶 TAB 2: SACRED AUDIO & SERMONS
  // ==========================================
  Widget _buildAudioSermonsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        children: [
          _buildHeroSection(),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('sermons')
                .orderBy('publishedDate', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 80.0),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(child: Text('Error loading audio: ${snapshot.error}')),
                );
              }

              // Empty State with Seed Action
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.audiotrack, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'No audio tracks posted yet.',
                          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload high-quality choir pieces and sermons, or populate with official SDA sample tracks.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Seed Sample Sacred Music'),
                          onPressed: _seedSampleTracks,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final List<Song> songs = snapshot.data!.docs.map((doc) {
                return Song.fromJson(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: songs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildSongTile(context, songs[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.music_note_rounded, color: AppTheme.sacredGold, size: 48),
          const SizedBox(height: 12),
          const Text(
            '"Music was made to serve a holy purpose, to lift the thoughts to that which is pure, noble, and elevating, and to awaken in the soul devotion and gratitude to God."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Patriarchs and Prophets, p. 594',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.sacredGold.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongTile(BuildContext context, Song song) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.music_note, color: AppTheme.primaryBlue),
        ),
        title: Text(
          song.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              song.artist,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            if (song.isPremium)
              Text(
                'Premium • Ksh ${song.price.toInt()}',
                style: const TextStyle(
                  color: AppTheme.sacredGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Text(
                'Free Access',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Share',
              icon: const Icon(Icons.share, size: 20, color: AppTheme.primaryBlue),
              onPressed: () => Share.share(song.generateShareText()),
            ),
            IconButton(
              tooltip: 'Delete Track',
              icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
              onPressed: () => _deleteAudioTrack(song.id, song.title),
            ),
            IconButton(
              tooltip: 'Play',
              icon: Icon(
                song.isPremium ? Icons.lock : Icons.play_circle_fill,
                color: song.isPremium ? AppTheme.sacredGold : AppTheme.primaryGreen,
                size: 32,
              ),
              onPressed: () => _handleSongTap(context, song),
            ),
          ],
        ),
        onTap: () => _handleSongTap(context, song),
      ),
    );
  }

  void _handleSongTap(BuildContext context, Song song) {
    if (song.isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioDetailScreen(
            audioId: song.id,
            title: song.title,
            speaker: song.artist,
            price: song.price.toInt(),
            audioUrl: song.audioUrl,
            songObject: song,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MusicPlayerScreen(song: song)),
      );
    }
  }
}
