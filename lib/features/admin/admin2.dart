import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Quote Controllers
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  // PDF Controllers
  final TextEditingController _pdfTitleController = TextEditingController();
  final TextEditingController _pdfCategoryController = TextEditingController();
  String? _selectedPdfPath;

  // Audio/Sermon Controllers
  final TextEditingController _sermonTitleController = TextEditingController();
  final TextEditingController _sermonSpeakerController =
      TextEditingController();
  String? _selectedAudioPath;

  // 🌿 Farming Article Controllers (The Final Tab)
  final TextEditingController _articleTitleController = TextEditingController();
  final TextEditingController _articleCategoryController =
      TextEditingController();
  final TextEditingController _articleDescController = TextEditingController();
  final TextEditingController _articleContentController =
      TextEditingController();

  bool _isSyncing = false;

  // ==========================================
  // 📁 FILE PICKER LOGIC
  // ==========================================
  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() => _selectedPdfPath = result.files.single.path);
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() => _selectedAudioPath = result.files.single.path);
    }
  }

  // ==========================================
  // 💾 OFFLINE HIVE QUEUE LOGIC
  // ==========================================
  void _saveToOfflineQueue(Map<String, dynamic> data) {
    final box = Hive.box(AppConstants.boxOfflineQueue);
    box.add(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Added to Sync Queue!'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _queueQuote() {
    if (_quoteController.text.isEmpty || _referenceController.text.isEmpty)
      return;
    _saveToOfflineQueue({
      'type': 'quote',
      'text': _quoteController.text.trim(),
      'reference': _referenceController.text.trim(),
      'title': 'Daily Quote',
    });
    _quoteController.clear();
    _referenceController.clear();
  }

  void _queuePdf() {
    if (_pdfTitleController.text.isEmpty || _selectedPdfPath == null) return;
    _saveToOfflineQueue({
      'type': 'pdf',
      'title': _pdfTitleController.text.trim(),
      'category': _pdfCategoryController.text.trim(),
      'filePath': _selectedPdfPath,
    });
    _pdfTitleController.clear();
    _pdfCategoryController.clear();
    setState(() => _selectedPdfPath = null);
  }

  void _queueSermon() {
    if (_sermonTitleController.text.isEmpty || _selectedAudioPath == null)
      return;
    _saveToOfflineQueue({
      'type': 'audio',
      'title': _sermonTitleController.text.trim(),
      'speaker': _sermonSpeakerController.text.trim(),
      'filePath': _selectedAudioPath,
    });
    _sermonTitleController.clear();
    _sermonSpeakerController.clear();
    setState(() => _selectedAudioPath = null);
  }

  void _queueArticle() {
    if (_articleTitleController.text.isEmpty ||
        _articleContentController.text.isEmpty) return;
    _saveToOfflineQueue({
      'type': 'article',
      'title': _articleTitleController.text.trim(),
      'category': _articleCategoryController.text.trim(),
      'description': _articleDescController.text.trim(),
      'content': _articleContentController.text.trim(),
      'author': AppConstants.developerName,
    });
    _articleTitleController.clear();
    _articleCategoryController.clear();
    _articleDescController.clear();
    _articleContentController.clear();
  }

  // ==========================================
  // 🚀 THE FIREBASE SYNC ENGINE
  // ==========================================
  Future<void> _syncToCloud() async {
    final box = Hive.box(AppConstants.boxOfflineQueue);
    if (box.isEmpty) return;

    setState(() => _isSyncing = true);

    try {
      for (int i = box.length - 1; i >= 0; i--) {
        final item = Map<String, dynamic>.from(box.getAt(i) as Map);
        final type = item['type'];

        if (type == 'quote') {
          await FirebaseFirestore.instance
              .collection(AppConstants.colDailyQuotes)
              .add({
            'text': item['text'],
            'reference': item['reference'],
            'displayDate': FieldValue.serverTimestamp(),
          });
        } else if (type == 'article') {
          await FirebaseFirestore.instance
              .collection(AppConstants.colFarmingArticles)
              .add({
            'title': item['title'],
            'category': item['category'],
            'shortDescription': item['description'],
            'content': item['content'],
            'author': item['author'],
            'publishedDate': FieldValue.serverTimestamp(),
          });
        } else if (type == 'pdf' || type == 'audio') {
          File file = File(item['filePath']);
          if (!await file.exists()) {
            await box.deleteAt(i);
            continue;
          }

          String fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
          String folderName = type == 'pdf' ? 'farming_pdfs' : 'sermons';

          Reference storageRef =
              FirebaseStorage.instance.ref().child('$folderName/$fileName');
          UploadTask uploadTask = storageRef.putFile(file);
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();

          if (type == 'pdf') {
            await FirebaseFirestore.instance
                .collection(AppConstants.colFarmingGuides)
                .add({
              'title': item['title'],
              'category': item['category'],
              'pdfUrl': downloadUrl,
              'publishedDate': FieldValue.serverTimestamp(),
            });
          } else {
            await FirebaseFirestore.instance
                .collection(AppConstants.colSermons)
                .add({
              'title': item['title'],
              'speaker': item['speaker'],
              'audioUrl': downloadUrl,
              'publishedDate': FieldValue.serverTimestamp(),
            });
          }
        }
        await box.deleteAt(i);
      }
      _showSnack('✅ All items synced to the Cloud!');
    } catch (e) {
      _showSnack('Sync Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.red : AppTheme.primaryGreen),
    );
  }

  // ==========================================
  // 🎨 UI BUILDER
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('VINE Admin'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppTheme.sacredGold,
            labelColor: AppTheme.sacredGold,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.format_quote), text: 'Quote'),
              Tab(icon: Icon(Icons.edit_note), text: 'Article'),
              Tab(icon: Icon(Icons.picture_as_pdf), text: 'PDF'),
              Tab(icon: Icon(Icons.mic), text: 'Audio'),
              Tab(icon: Icon(Icons.cloud_sync), text: 'Sync'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildQuoteTab(),
            _buildArticleTab(),
            _buildPdfTab(),
            _buildSermonTab(),
            _buildSyncTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSaveButton(
      {required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white)),
      ),
    );
  }

  Widget _buildQuoteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildField(_quoteController, 'Heavenly Wisdom (Quote Text)',
              maxLines: 4),
          _buildField(_referenceController, 'Reference (e.g. Ellen G. White)'),
          const SizedBox(height: 20),
          _buildSaveButton(label: 'QUEUE QUOTE', onTap: _queueQuote),
        ],
      ),
    );
  }

  Widget _buildArticleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildField(_articleTitleController, 'Article Title'),
          _buildField(
              _articleCategoryController, 'Category (e.g. Soil Health)'),
          _buildField(_articleDescController, 'Short Description', maxLines: 2),
          _buildField(_articleContentController, 'Full Educational Content',
              maxLines: 10),
          const SizedBox(height: 20),
          _buildSaveButton(label: 'QUEUE ARTICLE', onTap: _queueArticle),
        ],
      ),
    );
  }

  Widget _buildPdfTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildField(_pdfTitleController, 'Guide Title'),
          _buildField(_pdfCategoryController, 'Category'),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickPdf,
            icon: const Icon(Icons.attach_file),
            label: Text(
                _selectedPdfPath == null ? 'Select PDF File' : 'PDF Attached'),
          ),
          if (_selectedPdfPath != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_selectedPdfPath!.split('/').last,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          const SizedBox(height: 30),
          _buildSaveButton(label: 'QUEUE PDF', onTap: _queuePdf),
        ],
      ),
    );
  }

  Widget _buildSermonTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildField(_sermonTitleController, 'Sermon Title'),
          _buildField(_sermonSpeakerController, 'Speaker'),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickAudio,
            icon: const Icon(Icons.audiotrack),
            label: Text(_selectedAudioPath == null
                ? 'Select MP3 File'
                : 'Audio Attached'),
          ),
          if (_selectedAudioPath != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_selectedAudioPath!.split('/').last,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          const SizedBox(height: 30),
          _buildSaveButton(label: 'QUEUE SERMON', onTap: _queueSermon),
        ],
      ),
    );
  }

  Widget _buildSyncTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box(AppConstants.boxOfflineQueue).listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) {
          return const Center(
              child: Text('All content is synchronized with the Cloud.'));
        }
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.sacredGold.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${box.length} Items Waiting',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  _isSyncing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : ElevatedButton.icon(
                          onPressed: _syncToCloud,
                          icon: const Icon(Icons.upload, size: 18),
                          label: const Text('SYNC ALL'),
                        ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: box.length,
                itemBuilder: (context, index) {
                  final item =
                      Map<String, dynamic>.from(box.getAt(index) as Map);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                      child: Icon(_getIcon(item['type']),
                          size: 20, color: AppTheme.primaryBlue),
                    ),
                    title: Text(item['title'] ?? item['text'] ?? 'Untitled'),
                    subtitle: Text(item['type'].toString().toUpperCase()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => box.deleteAt(index),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'quote':
        return Icons.format_quote;
      case 'article':
        return Icons.edit_note;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.help_outline;
    }
  }
}
