import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';

class TestimoniesScreen extends StatefulWidget {
  const TestimoniesScreen({super.key});

  @override
  State<TestimoniesScreen> createState() => _TestimoniesScreenState();
}

class _TestimoniesScreenState extends State<TestimoniesScreen> {
  String _selectedCategory = 'All';
  final Set<String> _locallyAmened = {};

  final List<String> _categories = [
    'All',
    'Literature Evangelism',
    'Answered Prayer',
    'Health & Healing',
    'Conversion & Truth',
    'Providential Care',
  ];

  Future<void> _launchMediaUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleAmen(String docId, int currentCount) {
    if (_locallyAmened.contains(docId)) return;

    setState(() {
      _locallyAmened.add(docId);
    });

    // Cost-effective single field increment
    FirebaseFirestore.instance
        .collection('testimonies')
        .doc(docId)
        .update({'amenCount': FieldValue.increment(1)})
        .catchError((_) {});
  }

  void _showAddTestimonyDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final storyController = TextEditingController();
    final urlController = TextEditingController();
    String category = 'Literature Evangelism';
    String mediaType = 'text'; // 'text', 'tiktok', 'youtube', 'gdrive', 'link'
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Share Your Testimony',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Text(
                        'Overcome by the blood of the Lamb and the word of our testimony (Rev 12:11).',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Testimony Title *',
                          hintText: 'e.g. God Provided Books at the Camp Meeting',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Your Name (or Anonymous)',
                                hintText: 'e.g. Bro. David',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: locationController,
                              decoration: InputDecoration(
                                labelText: 'Location / City',
                                hintText: 'e.g. Nairobi, Kenya',
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: InputDecoration(
                          labelText: 'Testimony Category *',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _categories.where((c) => c != 'All').map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => category = val);
                        },
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: storyController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Your Experience & Praise *',
                          hintText: 'Describe how the Lord intervened or touched someone through your ministry...',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please share your story' : null,
                      ),
                      const SizedBox(height: 10),

                      // Optional Video/Audio link
                      TextFormField(
                        controller: urlController,
                        decoration: InputDecoration(
                          labelText: 'Optional Video / Audio Link (TikTok, YouTube, Drive)',
                          hintText: 'https://tiktok.com/@... or https://youtube.com/...',
                          prefixIcon: const Icon(Icons.link, size: 20),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.send),
                          label: Text(
                            isSubmitting ? 'Posting Testimony...' : 'POST TESTIMONY',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() => isSubmitting = true);

                                  try {
                                    final rawUrl = urlController.text.trim();
                                    if (rawUrl.contains('tiktok.com')) {
                                      mediaType = 'tiktok';
                                    } else if (rawUrl.contains('youtube.com') || rawUrl.contains('youtu.be')) {
                                      mediaType = 'youtube';
                                    } else if (rawUrl.contains('drive.google.com')) {
                                      mediaType = 'gdrive';
                                    } else if (rawUrl.isNotEmpty) {
                                      mediaType = 'link';
                                    }

                                    // Lightweight, cost-optimized flat document write
                                    await FirebaseFirestore.instance.collection('testimonies').add({
                                      'title': titleController.text.trim(),
                                      'author': nameController.text.trim().isEmpty ? 'Believer in Christ' : nameController.text.trim(),
                                      'location': locationController.text.trim().isEmpty ? 'Global Remnant' : locationController.text.trim(),
                                      'category': category,
                                      'story': storyController.text.trim(),
                                      'mediaUrl': rawUrl,
                                      'mediaType': mediaType,
                                      'amenCount': 1,
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });

                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Praise God! Your testimony has been posted.'),
                                        backgroundColor: AppTheme.primaryGreen,
                                      ),
                                    );
                                  } catch (e) {
                                    setModalState(() => isSubmitting = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error saving testimony: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Faith Testimonies', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Share App',
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                '🕊️ Read inspiring testimonies of God\'s power and Literature Evangelism on the Harvion SDA App!\nDownload today.',
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.record_voice_over),
        label: const Text('SHARE TESTIMONY', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showAddTestimonyDialog,
      ),
      body: Column(
        children: [
          // Hero Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.sacredGold.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volunteer_activism, color: AppTheme.sacredGold, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Power of Personal Witness',
                        style: TextStyle(color: AppTheme.sacredGold, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      Text(
                        'Miracles & Literature Evangelism',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Read how God moves hearts through answered prayer and colporteur outreach.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Category Chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppTheme.sacredGold,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),

          // Cost-effective Stream limited to 25 items
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('testimonies')
                  .orderBy('createdAt', descending: true)
                  .limit(25)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.sacredGold));
                }

                final docs = snapshot.hasData ? snapshot.data!.docs : [];
                final filtered = docs.where((d) {
                  if (_selectedCategory == 'All') return true;
                  final data = d.data() as Map<String, dynamic>;
                  return data['category'] == _selectedCategory;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.format_quote, size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'No testimonies in this category yet.',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Be the first to record what the Lord has done for your soul!',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Testimony'),
                            onPressed: _showAddTestimonyDialog,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    final title = data['title'] as String? ?? 'A Wonder of Grace';
                    final author = data['author'] as String? ?? 'Believer';
                    final location = data['location'] as String? ?? 'Global Remnant';
                    final category = data['category'] as String? ?? 'Evangelism';
                    final story = data['story'] as String? ?? '';
                    final mediaUrl = data['mediaUrl'] as String? ?? '';
                    final mediaType = data['mediaType'] as String? ?? 'text';
                    final rawAmenCount = (data['amenCount'] as int? ?? 1);
                    final isAmened = _locallyAmened.contains(docId);
                    final amenCount = isAmened ? rawAmenCount + 1 : rawAmenCount;

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    category.toUpperCase(),
                                    style: const TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (mediaType == 'tiktok')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('TikTok Video', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                  )
                                else if (mediaType == 'youtube')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('YouTube Praise', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Shared by $author • $location',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              story,
                              style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                            ),
                            if (mediaUrl.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryBlue,
                                  side: const BorderSide(color: AppTheme.primaryBlue),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                icon: const Icon(Icons.play_circle_fill, size: 16),
                                label: Text(
                                  mediaType == 'tiktok' ? 'Watch Video on TikTok' : 'Open Media Link',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => _launchMediaUrl(mediaUrl),
                              ),
                            ],
                            const Divider(height: 20),
                            Row(
                              children: [
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: isAmened ? AppTheme.primaryGreen : Colors.grey.shade700,
                                  ),
                                  icon: Icon(
                                    isAmened ? Icons.favorite : Icons.favorite_border,
                                    size: 18,
                                    color: isAmened ? Colors.redAccent : Colors.grey.shade700,
                                  ),
                                  label: Text(
                                    'Praise God ($amenCount)',
                                    style: TextStyle(
                                      fontWeight: isAmened ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onPressed: () => _handleAmen(docId, rawAmenCount),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.share, size: 18, color: Colors.grey),
                                  tooltip: 'Share testimony',
                                  onPressed: () {
                                    Share.share(
                                      '🕊️ *Testimony: $title*\n'
                                      'By $author ($location)\n\n'
                                      '"$story"\n\n'
                                      'Read more faith testimonies on the Harvion App!',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
