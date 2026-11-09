import 'dart:async';
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
  StreamSubscription<BatchDownloadStatus>? _batchStatusSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDownloadedHymns();

    // Listen to real-time batch downloads to update offline badges dynamically
    _batchStatusSub = SdaHymnAudioService().batchStatusStream.listen((status) {
      if (mounted) {
        _loadDownloadedHymns();
      }
    });
  }

  Future<void> _loadDownloadedHymns() async {
    final downloaded = await SdaHymnAudioService().getDownloadedHymnNumbers();
    if (mounted) {
      setState(() => _downloadedHymns = downloaded);
    }
  }

  @override
  void dispose() {
    _batchStatusSub?.cancel();
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
                        Icon(Icons.cloud_upload_rounded, color: AppTheme.primaryBlue, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Post New Sacred Audio',
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
                    labelText: 'Song / Sermon Title *',
                    hintText: 'e.g. Great Is Thy Faithfulness',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: artistCtrl,
                  decoration: InputDecoration(
                    labelText: 'Choir / Speaker Name *',
                    hintText: 'e.g. Heritage Singers / Pastor Mwangi',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Sacred Choir', child: Text('Sacred Choir')),
                    DropdownMenuItem(value: 'SDA Hymn', child: Text('SDA Hymn')),
                    DropdownMenuItem(value: 'Sermon', child: Text('Sermon')),
                    DropdownMenuItem(value: 'Devotional', child: Text('Devotional')),
                    DropdownMenuItem(value: 'Youth Praise', child: Text('Youth Praise')),
                    DropdownMenuItem(value: 'Instrumental', child: Text('Instrumental')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedCategory = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: InputDecoration(
                    labelText: 'Direct Audio MP3 URL *',
                    hintText: 'https://archive.org/... or hosted MP3',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Access Price (Ksh) — 0 for Free',
                    hintText: '0',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    isSubmitting ? 'Publishing...' : 'Publish Audio to Library',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                              const SnackBar(content: Text('Please fill all required fields.')),
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

                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Published "$title" successfully!'),
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
        'audioUrl': 'https://hymnal.pro/sda-hymnal/mp3/100.mp3',
        'category': 'Sacred Choir',
        'price': 0.0,
      },
      {
        'title': 'The Three Angels\' Messages Explained',
        'speaker': 'Pastor H.M.S. Richards',
        'audioUrl': 'https://hymnal.pro/sda-hymnal/mp3/001.mp3',
        'category': 'Sermon',
        'price': 0.0,
      },
      {
        'title': 'We Have This Hope (Advent Hymn)',
        'speaker': 'SDA General Conference Session Choir',
        'audioUrl': 'https://hymnal.pro/sda-hymnal/mp3/214.mp3',
        'category': 'SDA Hymn',
        'price': 0.0,
      },
      {
        'title': 'Holy Sabbath, Day of Rest',
        'speaker': 'East Africa Heritage Chorale',
        'audioUrl': 'https://hymnal.pro/sda-hymnal/mp3/381.mp3',
        'category': 'Sacred Choir',
        'price': 0.0,
      },
      {
        'title': 'God\'s Love for Man (Steps to Christ Ch. 1)',
        'speaker': 'HARVION Audio Ministry',
        'audioUrl': 'https://hymnal.pro/sda-hymnal/mp3/108.mp3',
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

  // ==========================================
  // ⚡ BATCH DOWNLOAD: DOWNLOAD ALL HYMNS
  // ==========================================
  void _startAndShowBatchDownload() {
    final titles = <int, String>{};
    for (final h in SdaHymnalData.hymns) {
      titles[h.number] = h.title;
    }

    SdaHymnAudioService().startBatchDownload(
      totalHymns: SdaHymnalData.hymns.length,
      hymnTitles: titles,
    );

    _showBatchDownloadSheet();
  }

  void _showBatchDownloadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StreamBuilder<BatchDownloadStatus>(
          stream: SdaHymnAudioService().batchStatusStream,
          initialData: SdaHymnAudioService().currentBatchStatus,
          builder: (context, snapshot) {
            final status = snapshot.data ?? const BatchDownloadStatus();
            final percent = (status.overallProgress * 100).toInt();

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.sacredGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.piano, color: AppTheme.primaryBlue, size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Offline Piano Pack',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                              ),
                              Text(
                                'All 695 SDA Hymnal Accompaniments',
                                style: TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Metric Progress Box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryBlue,
                                height: 1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: status.isRunning
                                    ? (status.isPaused ? Colors.amber.shade100 : Colors.green.shade100)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.isRunning
                                    ? (status.isPaused ? 'PAUSED' : 'DOWNLOADING')
                                    : (status.completed >= status.total ? 'COMPLETE' : 'IDLE'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: status.isRunning
                                      ? (status.isPaused ? Colors.amber.shade900 : Colors.green.shade900)
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: status.overallProgress > 0 ? status.overallProgress : null,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${status.completed} of ${status.total} hymns downloaded',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                            Text(
                              '${status.total - status.completed} left',
                              style: const TextStyle(fontSize: 11, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Current Track Progress Details
                  if (status.isRunning && status.currentHymnNumber > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.music_note, size: 14, color: AppTheme.sacredGold),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Current: Hymn #${status.currentHymnNumber} • ${status.currentHymnTitle}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBlue),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${(status.currentHymnProgress * 100).toInt()}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryBlue),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: status.currentHymnProgress > 0 ? status.currentHymnProgress : null,
                              minHeight: 4,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.sacredGold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),

                  // Action Buttons Row
                  if (status.isRunning)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: status.isPaused ? Colors.green.shade800 : AppTheme.primaryBlue,
                              side: BorderSide(color: status.isPaused ? Colors.green : AppTheme.primaryBlue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: Icon(status.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                            label: Text(status.isPaused ? 'Resume' : 'Pause'),
                            onPressed: () {
                              if (status.isPaused) {
                                SdaHymnAudioService().resumeBatchDownload();
                              } else {
                                SdaHymnAudioService().pauseBatchDownload();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.stop_rounded),
                            label: const Text('Cancel'),
                            onPressed: () {
                              SdaHymnAudioService().cancelBatchDownload();
                              _loadDownloadedHymns();
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.cloud_download_rounded),
                      label: Text(status.completed >= status.total ? 'All Hymns Downloaded' : 'Start Downloading Remaining Tracks'),
                      onPressed: status.completed >= status.total
                          ? null
                          : () {
                              final titles = <int, String>{};
                              for (final h in SdaHymnalData.hymns) {
                                titles[h.number] = h.title;
                              }
                              SdaHymnAudioService().startBatchDownload(
                                totalHymns: SdaHymnalData.hymns.length,
                                hymnTitles: titles,
                              );
                            },
                    ),

                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _loadDownloadedHymns();
                    },
                    child: const Text('Keep Downloading in Background', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBatchDownloadBanner() {
    return StreamBuilder<BatchDownloadStatus>(
      stream: SdaHymnAudioService().batchStatusStream,
      initialData: SdaHymnAudioService().currentBatchStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? const BatchDownloadStatus();
        final isRunning = status.isRunning;
        final totalCount = SdaHymnalData.hymns.length;
        final downloadedCount = _downloadedHymns.length;
        final isAllDownloaded = downloadedCount >= totalCount && totalCount > 0;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAllDownloaded
                  ? Colors.green.shade400
                  : (isRunning ? AppTheme.primaryBlue : AppTheme.sacredGold.withValues(alpha: 0.6)),
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
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isAllDownloaded
                          ? Colors.green.shade50
                          : (isRunning ? AppTheme.primaryBlue.withValues(alpha: 0.1) : AppTheme.sacredGold.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isAllDownloaded
                          ? Icons.offline_pin_rounded
                          : (isRunning ? Icons.cloud_download_rounded : Icons.piano),
                      color: isAllDownloaded
                          ? Colors.green.shade700
                          : AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAllDownloaded
                              ? 'Offline Piano Pack Ready (All 695 Hymns)'
                              : (isRunning ? 'Downloading Piano Pack...' : 'Complete Offline Piano Pack'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: isAllDownloaded ? Colors.green.shade800 : AppTheme.primaryBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAllDownloaded
                              ? 'All 695 piano accompaniments saved. Zero data needed!'
                              : (isRunning
                                  ? 'Saved ${status.completed} / ${status.total} hymns (${(status.overallProgress * 100).toInt()}%)'
                                  : 'Downloaded $downloadedCount of $totalCount piano tracks (${(downloadedCount / (totalCount > 0 ? totalCount : 1) * 100).toInt()}%)'),
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (isRunning) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: status.overallProgress > 0 ? status.overallProgress : null,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                    minHeight: 7,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        status.message.isNotEmpty
                            ? status.message
                            : 'Downloading hymn audio tracks...',
                        style: const TextStyle(fontSize: 10.5, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(status.overallProgress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(color: AppTheme.primaryBlue),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: Icon(status.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 16),
                        label: Text(status.isPaused ? 'Resume' : 'Pause', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          if (status.isPaused) {
                            SdaHymnAudioService().resumeBatchDownload();
                          } else {
                            SdaHymnAudioService().pauseBatchDownload();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.fullscreen_rounded, size: 16),
                        label: const Text('View Progress', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: _showBatchDownloadSheet,
                      ),
                    ),
                  ],
                ),
              ] else if (!isAllDownloaded) ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.cloud_download_rounded, size: 18),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'DOWNLOAD ALL PIANO TRACKS (${totalCount - downloadedCount} REMAINING)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, letterSpacing: 0.5),
                    ),
                  ),
                  onPressed: _startAndShowBatchDownload,
                ),
              ],
            ],
          ),
        );
      },
    );
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
        // Batch Download All Hymns Card
        _buildBatchDownloadBanner(),

        // Search & Category Bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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

        // Hymn Count Header (Safe from pixel overflow)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Showing ${hymns.length} Hymns',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.piano, color: AppTheme.primaryBlue, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Piano (Sing Along)',
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

                // Details (Overflow proof)
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
                          Flexible(
                            child: Container(
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
  // 🎙️ TAB 2: SACRED AUDIO & SERMONS
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
