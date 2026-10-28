import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../services/harvion_database_service.dart';
import '../bookstore/models/physical_book_model.dart';
import '../sermons/sermon_model.dart';
import '../sermons/video_player_screen.dart';
import '../family/models/family_pillar_model.dart';
import 'admin_book_editor.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isSeedingDb = false;

  // Video / Livestream Controllers
  final _videoTitleController = TextEditingController();
  final _videoSpeakerController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _videoSeriesController = TextEditingController(text: 'General Sermons');
  final _videoDescController = TextEditingController();
  bool _isLiveStream = false;

  // Daily Quote Controllers
  final _quoteTextController = TextEditingController();
  final _quoteRefController = TextEditingController();

  @override
  void dispose() {
    _videoTitleController.dispose();
    _videoSpeakerController.dispose();
    _videoUrlController.dispose();
    _videoSeriesController.dispose();
    _videoDescController.dispose();
    _quoteTextController.dispose();
    _quoteRefController.dispose();
    super.dispose();
  }

  Future<void> _seedWholeDatabase() async {
    setState(() => _isSeedingDb = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting full HARVION database initialization...'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final results = await HarvionDatabaseService().seedCompleteFirebaseDatabase(
        onProgress: (msg) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), duration: const Duration(milliseconds: 800)),
            );
          }
        },
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.primaryGreen),
                SizedBox(width: 8),
                Text('Database Seeded!'),
              ],
            ),
            content: Text(
              'Successfully seeded collections in vine-3e4ab:\n\n'
              '• bookstore_items: ${results['bookstore_items']} books\n'
              '• devotionals & quotes: ${results['devotionals']}\n'
              '• colporteurs: ${results['colporteurs']}\n'
              '• healthy_recipes: ${results['healthy_recipes']}\n'
              '• churches_directory: ${results['churches_directory']}\n'
              '• prayer_requests: ${results['prayer_requests']}\n'
              '• digital_tracts: ${results['digital_tracts']}\n',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seeding failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeedingDb = false);
    }
  }

  // ==========================================
  // 📚 DELETE BOOK
  // ==========================================
  Future<void> _deleteBook(String bookId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to remove "$title" from the Literature Evangelism catalog?'),
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
      await FirebaseFirestore.instance.collection('bookstore_items').doc(bookId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed "$title"'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==========================================
  // 👥 APPROVE / REJECT SELLER REQUEST
  // ==========================================
  Future<void> _approveSellerRequest(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    // 1. Add directly to bookstore_items
    final newBookData = {
      'title': data['bookTitle'] ?? 'Untitled',
      'author': data['author'] ?? 'Ellen G. White',
      'category': data['category'] ?? 'Spirit of Prophecy',
      'description': data['description'] ?? '',
      'price': (data['price'] ?? 0).toDouble(),
      'originalPrice': (data['originalPrice'] ?? data['price'] ?? 0).toDouble(),
      'format': data['hasHardCopy'] == true && data['hasSoftCopy'] == true
          ? 'Hardcover & Soft Copy'
          : (data['hasSoftCopy'] == true ? 'Digital PDF' : 'Paperback'),
      'hasHardCopy': data['hasHardCopy'] ?? true,
      'hasSoftCopy': data['hasSoftCopy'] ?? false,
      'softCopyPrice': data['softCopyPrice'],
      'softCopyUrl': data['softCopyUrl'],
      'language': 'English',
      'coverImageUrl': data['coverImageUrl'] ?? '',
      'previewImages': data['previewImages'] ?? [],
      'inStock': true,
      'pageCount': data['pageCount'] ?? 250,
      'rating': 5.0,
      'isbn': data['isbn'] ?? '',
      'isFeatured': false,
      'colporteurCommissionNote': 'Distributed by ${data['sellerName'] ?? 'Literature Evangelist'}',
      'sellerName': data['sellerName'],
      'sellerPhone': data['sellerPhone'],
      'sellerId': doc.id,
      'isApproved': true,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('bookstore_items').add(newBookData);

    // 2. Mark request as approved
    await doc.reference.update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Approved "${data['bookTitle']}"! Now live on Harvion Bookstore.'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  Future<void> _rejectSellerRequest(DocumentSnapshot doc) async {
    await doc.reference.update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request marked as rejected.'), backgroundColor: Colors.orange),
      );
    }
  }

  // ==========================================
  // 🎥 SAVE VIDEO & INSTANT PREVIEW
  // ==========================================
  Future<void> _saveVideo({bool previewOnly = false}) async {
    final title = _videoTitleController.text.trim();
    final url = _videoUrlController.text.trim();
    final speaker = _videoSpeakerController.text.trim();
    final series = _videoSeriesController.text.trim();
    final desc = _videoDescController.text.trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a video or livestream URL.')),
      );
      return;
    }

    final sermon = Sermon(
      id: 'preview_${DateTime.now().millisecondsSinceEpoch}',
      title: title.isNotEmpty ? title : 'Live Video Session',
      speaker: speaker.isNotEmpty ? speaker : 'Pastor / Speaker',
      description: desc,
      mediaUrl: url,
      type: SermonMediaType.video,
      datePreached: DateTime.now(),
      seriesName: series.isNotEmpty ? series : 'General Sermons',
      duration: const Duration(minutes: 45),
      isLiveStream: _isLiveStream,
    );

    if (previewOnly) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(sermon: sermon)),
      );
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a title for the video.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('sermons').add({
      'title': title,
      'speaker': speaker,
      'mediaUrl': url,
      'seriesName': series,
      'description': desc,
      'type': 'video',
      'isLiveStream': _isLiveStream,
      'liveViewerCount': _isLiveStream ? 12 : 0,
      'publishedDate': FieldValue.serverTimestamp(),
    });

    _videoTitleController.clear();
    _videoUrlController.clear();
    _videoSpeakerController.clear();
    _videoDescController.clear();
    setState(() => _isLiveStream = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video / Livestream published successfully!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  // ==========================================
  // 🏡 ADD / EDIT ADVENTIST HOME PILLAR
  // ==========================================
  void _showAddPillarDialog([FamilyPillar? pillarToEdit]) {
    final titleController = TextEditingController(text: pillarToEdit?.title ?? '');
    final subtitleController = TextEditingController(text: pillarToEdit?.subtitle ?? '');
    final descController = TextEditingController(text: pillarToEdit?.description ?? '');
    final egwQuoteController = TextEditingController(text: pillarToEdit?.egwQuote ?? '');
    final egwSourceController = TextEditingController(text: pillarToEdit?.egwSource ?? 'The Adventist Home');
    final videoLinkController = TextEditingController(text: pillarToEdit?.videoLink ?? '');
    String iconName = pillarToEdit?.iconName ?? 'favorite';
    String colorHex = pillarToEdit?.colorHex ?? '0xFFE91E63';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(pillarToEdit != null ? 'Edit Adventist Home Pillar' : 'New Home Pillar',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Pillar Title *')),
              const SizedBox(height: 8),
              TextField(controller: subtitleController, decoration: const InputDecoration(labelText: 'Subtitle / Theme')),
              const SizedBox(height: 8),
              TextField(controller: descController, maxLines: 2, decoration: const InputDecoration(labelText: 'Overview Description')),
              const SizedBox(height: 8),
              TextField(controller: egwQuoteController, maxLines: 3, decoration: const InputDecoration(labelText: 'E.G. White Quote')),
              const SizedBox(height: 8),
              TextField(controller: egwSourceController, decoration: const InputDecoration(labelText: 'EGW Source Book & Page')),
              const SizedBox(height: 8),
              TextField(controller: videoLinkController, decoration: const InputDecoration(labelText: 'Video / Livestream Link (YouTube / Drive)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;

              final pillarData = {
                'title': titleController.text.trim(),
                'subtitle': subtitleController.text.trim(),
                'description': descController.text.trim(),
                'egwQuote': egwQuoteController.text.trim(),
                'egwSource': egwSourceController.text.trim(),
                'videoLink': videoLinkController.text.trim(),
                'iconName': iconName,
                'colorHex': colorHex,
                'isPublished': true,
                'updatedAt': FieldValue.serverTimestamp(),
              };

              if (pillarToEdit != null) {
                await FirebaseFirestore.instance.collection('family_pillars').doc(pillarToEdit.id).update(pillarData);
              } else {
                pillarData['orderIndex'] = 10;
                await FirebaseFirestore.instance.collection('family_pillars').add(pillarData);
              }

              Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pillar saved successfully!'), backgroundColor: AppTheme.primaryGreen),
                );
              }
            },
            child: const Text('SAVE PILLAR'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ☀️ ADD DAILY QUOTE
  // ==========================================
  Future<void> _saveQuote() async {
    final text = _quoteTextController.text.trim();
    final ref = _quoteRefController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance.collection('daily_quotes').add({
      'text': text,
      'reference': ref.isNotEmpty ? ref : 'Spirit of Prophecy',
      'displayDate': FieldValue.serverTimestamp(),
    });

    _quoteTextController.clear();
    _quoteRefController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily Quote published to Home Screen!'), backgroundColor: AppTheme.primaryGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('HARVION Admin Control Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: 'Seed Complete Database',
              icon: _isSeedingDb
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.cloud_upload_outlined),
              onPressed: _isSeedingDb ? null : _seedWholeDatabase,
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppTheme.sacredGold,
            indicatorWeight: 3,
            labelColor: AppTheme.sacredGold,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: 'LE Books'),
              Tab(icon: Icon(Icons.how_to_reg), text: 'Seller Approvals'),
              Tab(icon: Icon(Icons.video_library), text: 'Videos & Live'),
              Tab(icon: Icon(Icons.family_restroom), text: 'Family Pillars'),
              Tab(icon: Icon(Icons.format_quote), text: 'Quotes & Seed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBooksTab(),
            _buildSellerApprovalsTab(),
            _buildVideosTab(),
            _buildFamilyPillarsTab(),
            _buildQuotesAndSeederTab(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: LITERATURE EVANGELISM BOOKS
  // ==========================================
  Widget _buildBooksTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('ADD NEW BOOK', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookEditorScreen()));
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookstore_items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          List<PhysicalBook> books = [];
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            books = snapshot.data!.docs.map((doc) {
              return PhysicalBook.fromJson(doc.data() as Map<String, dynamic>, doc.id);
            }).toList();
          } else {
            books = PhysicalBook.getSampleBooks();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final book = books[index];
              final hasCover = book.coverImageUrl.isNotEmpty &&
                  (book.coverImageUrl.startsWith('http://') || book.coverImageUrl.startsWith('https://'));

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: hasCover
                          ? Image.network(book.coverImageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.book))
                          : const Icon(Icons.menu_book, color: AppTheme.primaryBlue),
                    ),
                  ),
                  title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text('By ${book.author} • ${book.category}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Ksh ${book.price.toInt()}',
                              style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 8),
                          if (book.hasSoftCopy)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                              child: const Text('Soft Copy', style: TextStyle(fontSize: 9, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.primaryBlue, size: 20),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AdminBookEditorScreen(bookToEdit: book)),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _deleteBook(book.id, book.title),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 2: SELLER APPROVALS QUEUE
  // ==========================================
  Widget _buildSellerApprovalsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('book_seller_requests')
          .orderBy('submittedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 54, color: AppTheme.primaryGreen),
                SizedBox(height: 12),
                Text('No Pending Book Seller Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Colporteur submissions will appear here for verification.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        final requests = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final doc = requests[index];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            final title = data['bookTitle'] ?? 'Untitled';
            final seller = data['sellerName'] ?? 'Colporteur';
            final phone = data['sellerPhone'] ?? '';
            final price = data['price'] ?? 0;
            final coverUrl = data['coverImageUrl'] ?? '';

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'approved'
                                ? Colors.green.shade50
                                : (status == 'rejected' ? Colors.red.shade50 : Colors.amber.shade50),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: status == 'approved'
                                  ? Colors.green.shade800
                                  : (status == 'rejected' ? Colors.red : Colors.orange.shade800),
                            ),
                          ),
                        ),
                        Text('Phone: $phone', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Book Details & Cover
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (coverUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(coverUrl, width: 60, height: 85, fit: BoxFit.cover),
                          )
                        else
                          Container(
                            width: 60,
                            height: 85,
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.menu_book, color: AppTheme.primaryBlue),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('Author: ${data['author'] ?? ''}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                              Text('Submitted by: $seller', style: const TextStyle(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Proposed Price: Ksh $price', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (data['description'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        data['description'],
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Divider(height: 20),

                    // Approve / Reject Actions
                    if (status == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              onPressed: () => _rejectSellerRequest(doc),
                              child: const Text('REJECT'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('APPROVE & PUBLISH'),
                              onPressed: () => _approveSellerRequest(doc),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        status == 'approved' ? '✅ Published on Bookstore' : '❌ Application Declined',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: status == 'approved' ? AppTheme.primaryGreen : Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 3: VIDEOS & LIVESTREAMS
  // ==========================================
  Widget _buildVideosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Broadcast Sermons, Teachings & Livestreams',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add YouTube live links, Google Drive teachings, or direct video URLs. Users can watch live with interactive prayer comments.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          TextField(controller: _videoTitleController, decoration: const InputDecoration(labelText: 'Teaching / Sermon Title *')),
          const SizedBox(height: 12),
          TextField(controller: _videoSpeakerController, decoration: const InputDecoration(labelText: 'Speaker / Preacher Name')),
          const SizedBox(height: 12),
          TextField(
            controller: _videoUrlController,
            decoration: const InputDecoration(
              labelText: 'Video / Livestream URL (YouTube, Google Drive, MP4, HLS) *',
              hintText: 'https://www.youtube.com/watch?v=... or https://drive.google.com/...',
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: _videoSeriesController, decoration: const InputDecoration(labelText: 'Series Name (e.g. Family Life Sessions, Prophecy)')),
          const SizedBox(height: 12),
          TextField(controller: _videoDescController, maxLines: 2, decoration: const InputDecoration(labelText: 'Summary Description')),
          const SizedBox(height: 8),

          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('This is an Active Livestream', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Displays "🔴 LIVE NOW" badge and live interactive chat room for users'),
            value: _isLiveStream,
            activeColor: Colors.red,
            onChanged: (val) => setState(() => _isLiveStream = val ?? false),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('PREVIEW VIDEO'),
                  onPressed: () => _saveVideo(previewOnly: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('PUBLISH VIDEO'),
                  onPressed: () => _saveVideo(previewOnly: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          const Text('Recently Published Video Sessions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue)),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('sermons').orderBy('publishedDate', descending: true).limit(5).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No videos added yet.', style: TextStyle(color: Colors.grey));
              }

              final docs = snapshot.data!.docs;
              return Column(
                children: docs.map((d) {
                  final s = Sermon.fromJson(d.data() as Map<String, dynamic>, d.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(s.isLiveStream ? Icons.live_tv : Icons.play_arrow,
                          color: s.isLiveStream ? Colors.red : AppTheme.primaryGreen),
                      title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('${s.speaker} • ${s.seriesName}', style: const TextStyle(fontSize: 11)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                        onPressed: () => d.reference.delete(),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(sermon: s)));
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: FAMILY PILLARS MANAGER
  // ==========================================
  Widget _buildFamilyPillarsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('ADD PILLAR'),
        onPressed: () => _showAddPillarDialog(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('family_pillars').orderBy('orderIndex').snapshots(),
        builder: (context, snapshot) {
          List<FamilyPillar> pillars = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            pillars = snapshot.data!.docs.map((doc) {
              return FamilyPillar.fromJson(doc.data() as Map<String, dynamic>, doc.id);
            }).toList();
          } else {
            pillars = FamilyPillar.getMockPillars();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: pillars.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final pillar = pillars[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: pillar.color.withOpacity(0.15),
                    child: Icon(pillar.iconData, color: pillar.color),
                  ),
                  title: Text(pillar.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(pillar.subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.primaryBlue, size: 20),
                        onPressed: () => _showAddPillarDialog(pillar),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('family_pillars').doc(pillar.id).delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 5: QUOTES & DATABASE SEEDER
  // ==========================================
  Widget _buildQuotesAndSeederTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Database Seeder Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storage, color: AppTheme.sacredGold, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Complete Database Seeder',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seeds all books (Hard & Soft copies), Adventist Home Pillars, Colporteur spots, sermons, and digital tracts into project vine-3e4ab.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.sacredGold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isSeedingDb ? null : _seedWholeDatabase,
                    child: _isSeedingDb
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('RUN COMPLETE DATABASE SEEDER NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Daily Quote Publisher
          const Text('Publish Daily Quote (Home Screen)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue)),
          const SizedBox(height: 8),
          TextField(controller: _quoteTextController, maxLines: 3, decoration: const InputDecoration(labelText: 'Inspirational Quote *')),
          const SizedBox(height: 10),
          TextField(controller: _quoteRefController, decoration: const InputDecoration(labelText: 'Reference (e.g. Ellen G. White, Education p. 18)')),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.send),
              label: const Text('PUBLISH DAILY QUOTE'),
              onPressed: _saveQuote,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
