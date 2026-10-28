import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import '../auth/auth_screen.dart';
import '../subscription/payment_screen.dart';
import 'book_model.dart';
import 'pdf_viewer_screen.dart';
import 'sop_book_reader_screen.dart';
import 'services/online_reader_service.dart';

class PdfDetailScreen extends StatefulWidget {
  final String pdfId;
  final String title;
  final String description; // The Free Preview
  final int price; // 0 means FREE
  final String pdfUrl;
  final Book bookObject;

  const PdfDetailScreen({
    super.key,
    required this.pdfId,
    required this.title,
    required this.description,
    required this.price,
    required this.pdfUrl,
    required this.bookObject,
  });

  @override
  State<PdfDetailScreen> createState() => _PdfDetailScreenState();
}

class _PdfDetailScreenState extends State<PdfDetailScreen> {
  bool _hasPurchased = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPurchaseStatus();
  }

  // System remembers if they already paid!
  Future<void> _checkPurchaseStatus() async {
    if (widget.price == 0) {
      if (mounted) {
        setState(() {
          _hasPurchased = true; // Free items are automatically "purchased"
          _isLoading = false;
        });
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return; // Not logged in, definitely hasn't purchased
    }

    // Check user's profile in Firestore for this specific PDF ID
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final List<dynamic> purchasedItems =
            doc.data()?['purchasedItems'] ?? [];
        if (purchasedItems.contains(widget.pdfId) ||
            doc.data()?['role'] == 'admin') {
          _hasPurchased = true;
        }
      }
    } catch (e) {
      debugPrint("Error checking purchase: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleUnlockClick() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to purchase this guide.")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      ).then((_) => _checkPurchaseStatus());
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          itemId: widget.pdfId,
          itemName: widget.title,
          price: widget.price,
        ),
      ),
    ).then((_) => _checkPurchaseStatus());
  }

  void _openPdf() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(book: widget.bookObject),
      ),
    );
  }

  void _openReaderMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SopBookReaderScreen(book: widget.bookObject),
      ),
    );
  }

  void _openOnlineReader() {
    OnlineReaderService.openOnlineBook(
      context,
      widget.bookObject.effectiveOnlineUrl,
      title: widget.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFree = widget.price == 0;
    final series = widget.bookObject.series;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Book & Guide Details'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Read Online (Official)',
            icon: const Icon(Icons.public),
            onPressed: _openOnlineReader,
          ),
          IconButton(
            tooltip: 'Share Book',
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(widget.bookObject.generateShareText());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges (Free vs Premium + Series)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isFree ? AppTheme.primaryGreen : AppTheme.sacredGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isFree ? 'FREE ACCESS' : 'PREMIUM GUIDE',
                          style: TextStyle(
                            color: isFree ? Colors.white : AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (series != null && series.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            series,
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.bookObject.category,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Author: ${widget.bookObject.author}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // FREE PREVIEW SECTION
                  const Text(
                    "Overview & Summary:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ONLINE READING OFFICIAL CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.public, color: AppTheme.sacredGold, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Official EGW Writings Reader",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              Text(
                                "Read full unabridged text online with official Ellen G. White estate links.",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // THE ACTION BUTTONS
                  if (_hasPurchased) ...[
                    // 1. Read Online Button (Primary)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _openOnlineReader,
                        icon: const Icon(Icons.public, color: AppTheme.sacredGold),
                        label: const Text(
                          "READ ONLINE (OFFICIAL EGW WRITINGS)",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Read in Chapter Mode
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _openReaderMode,
                        icon: const Icon(Icons.auto_stories, color: Colors.white),
                        label: const Text(
                          "READ OFFLINE (CHAPTER VIEW)",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Download / View Full PDF
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _openPdf,
                        icon: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryBlue),
                        label: const Text(
                          "DOWNLOAD / VIEW FULL PDF",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.sacredGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _handleUnlockClick,
                        icon: const Icon(Icons.lock_open, color: AppTheme.primaryBlue),
                        label: Text(
                          "UNLOCK FOR KSh ${widget.price}",
                          style: const TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
