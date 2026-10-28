import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import 'sermon_model.dart';
import 'video_player_screen.dart';

class CreateLiveStreamScreen extends StatefulWidget {
  const CreateLiveStreamScreen({super.key});

  @override
  State<CreateLiveStreamScreen> createState() => _CreateLiveStreamScreenState();
}

class _CreateLiveStreamScreenState extends State<CreateLiveStreamScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _speakerController = TextEditingController();
  final TextEditingController _ministryController = TextEditingController(text: 'Harvion Mission Outpost');
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _platform = 'tiktok'; // 'tiktok', 'youtube', 'google_drive', 'direct'
  String _language = 'English';
  String _category = 'Sabbath Worship';

  bool _agreedDoctrine = false;
  bool _agreedConduct = false;
  bool _isPublishing = false;

  final List<String> _languages = [
    'English',
    'Swahili',
    'French',
    'Spanish',
    'Portuguese',
    'Luganda',
    'Amharic',
    'German',
    'Korean',
    'Chinese',
  ];

  final List<String> _categories = [
    'Sabbath Worship',
    'Health & NEWSTART',
    'Prophecy & Daniel/Revelation',
    'Family Life & Pillars',
    'Literature Evangelism',
    'Youth & Adventurers',
    'Community Prayer Hour',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _speakerController.dispose();
    _ministryController.dispose();
    _urlController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitBroadcast() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedDoctrine || !_agreedConduct) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the SDA Code of Conduct & Biblical Standards to broadcast.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      String cleanUrl = _urlController.text.trim();
      if (_platform == 'tiktok' && !cleanUrl.startsWith('http')) {
        final handle = cleanUrl.startsWith('@') ? cleanUrl : '@$cleanUrl';
        cleanUrl = 'https://www.tiktok.com/$handle/live';
      }

      final sermonRef = FirebaseFirestore.instance.collection('sermons').doc();
      final now = DateTime.now();

      final newSermon = Sermon(
        id: sermonRef.id,
        title: _titleController.text.trim(),
        speaker: _speakerController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? 'Live spiritual message broadcast via Harvion SDA Platform.'
            : _descController.text.trim(),
        mediaUrl: cleanUrl,
        type: SermonMediaType.video,
        datePreached: now,
        seriesName: _category,
        duration: Duration.zero,
        isLiveStream: true,
        liveViewerCount: 1,
        videoSourceType: _platform,
        language: _language,
        ministryName: _ministryController.text.trim(),
        codeOfConductAccepted: true,
      );

      // 1. Save to sermons collection
      await sermonRef.set({
        ...newSermon.toJson(),
        'publishedDate': FieldValue.serverTimestamp(),
      });

      // 2. Broadcast real-time announcement to all users
      await FirebaseFirestore.instance.collection('live_announcements').doc(sermonRef.id).set({
        'sermonId': sermonRef.id,
        'title': newSermon.title,
        'speaker': newSermon.speaker,
        'ministryName': newSermon.ministryName,
        'language': newSermon.language,
        'mediaUrl': cleanUrl,
        'platform': _platform,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔴 Live Broadcast Started! All Harvion users have been notified.'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );

      // Navigate directly to the live player
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => VideoPlayerScreen(sermon: newSermon)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish stream: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Start Live Broadcast', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Callout
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D3B66), Color(0xFF1F5F8B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.podcasts, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Global SDA Evangelism',
                            style: TextStyle(color: AppTheme.sacredGold, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Broadcast to Believers Worldwide',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Add your TikTok, YouTube, or Drive stream. Users will receive instant live notifications.',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text('1. Choose Broadcast Platform',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue)),
              const SizedBox(height: 10),

              // Platform Selector Cards
              Row(
                children: [
                  _buildPlatformCard('tiktok', 'TikTok LIVE', Icons.videocam, const Color(0xFF000000)),
                  const SizedBox(width: 8),
                  _buildPlatformCard('youtube', 'YouTube LIVE', Icons.play_arrow, Colors.red.shade700),
                  const SizedBox(width: 8),
                  _buildPlatformCard('google_drive', 'Drive / Link', Icons.cloud_upload, Colors.blue.shade700),
                ],
              ),

              const SizedBox(height: 16),

              // TikTok Guidance Card
              if (_platform == 'tiktok')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.live_tv, color: Colors.black, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'How to link your TikTok Live:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Open TikTok on your mobile device.\n'
                        '2. Tap the (+) button, swipe right to LIVE, and start your stream.\n'
                        '3. Enter your TikTok @username (e.g. @pastor_samuel) or full live URL below.\n'
                        '4. Harvion believers will instantly see your live stream and can join directly in-app or via TikTok!',
                        style: TextStyle(fontSize: 12, height: 1.5, color: Colors.black87),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              const Text('2. Broadcast Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue)),
              const SizedBox(height: 12),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Sermon / Broadcast Title *',
                  hintText: 'e.g. The Everlasting Gospel in the Last Days',
                  prefixIcon: const Icon(Icons.title, color: AppTheme.primaryBlue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _speakerController,
                      decoration: InputDecoration(
                        labelText: 'Preacher / Speaker Name *',
                        hintText: 'e.g. Pastor John Mwangi',
                        prefixIcon: const Icon(Icons.person, color: AppTheme.primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Enter speaker name' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _ministryController,
                      decoration: InputDecoration(
                        labelText: 'Ministry / Church Outpost',
                        hintText: 'e.g. Berean Media',
                        prefixIcon: const Icon(Icons.church, color: AppTheme.primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: _platform == 'tiktok'
                      ? 'TikTok Live Link or @Username *'
                      : 'Live Stream URL (YouTube, Drive, or HLS) *',
                  hintText: _platform == 'tiktok'
                      ? 'e.g. @pastor_john or https://www.tiktok.com/@pastor_john/live'
                      : 'https://youtube.com/live/... or https://drive.google.com/...',
                  prefixIcon: Icon(
                    _platform == 'tiktok' ? Icons.tag : Icons.link,
                    color: AppTheme.primaryBlue,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please provide the stream link/username' : null,
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  // Language Selector
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _language,
                      decoration: InputDecoration(
                        labelText: 'Language *',
                        prefixIcon: const Icon(Icons.translate, color: AppTheme.primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _languages.map((lang) {
                        return DropdownMenuItem(value: lang, child: Text(lang));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _language = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Category Selector
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      decoration: InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: const Icon(Icons.category, color: AppTheme.primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Brief Summary / Scripture Text',
                  hintText: 'Share the key text, theme, and invitation for viewers...',
                  prefixIcon: const Icon(Icons.description, color: AppTheme.primaryBlue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 24),
              const Text('3. Seventh-day Adventist Code of Conduct',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue)),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _agreedDoctrine,
                      activeColor: AppTheme.primaryGreen,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'I affirm this broadcast is Bible-based and upholds SDA Fundamental Beliefs.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) => setState(() => _agreedDoctrine = val ?? false),
                    ),
                    const Divider(height: 8),
                    CheckboxListTile(
                      value: _agreedConduct,
                      activeColor: AppTheme.primaryGreen,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'I will maintain Christian modesty, reverence, and respect for all viewers worldwide.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) => setState(() => _agreedConduct = val ?? false),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: _isPublishing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.broadcast_on_personal, color: Colors.white),
                  label: Text(
                    _isPublishing ? 'Broadcasting & Notifying...' : 'START BROADCAST & NOTIFY ALL USERS',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isPublishing ? null : _submitBroadcast,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformCard(String id, String label, IconData icon, Color color) {
    final isSelected = _platform == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _platform = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? color : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
