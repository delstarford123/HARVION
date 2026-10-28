import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../auth/auth_screen.dart';
import '../subscription/payment_screen.dart';
import 'book_model.dart';
import 'pdf_viewer_screen.dart';
import 'sop_book_reader_screen.dart';

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
      // User wants to buy, but isn't logged in. Force login NOW.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to purchase this guide.")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      ).then((_) => _checkPurchaseStatus()); // Re-check after return
      return;
    }

    // User is logged in. Trigger the Real M-Pesa Payment Screen!
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          itemId: widget.pdfId,
          itemName: widget.title,
          price: widget.price,
        ),
      ),
    ).then((_) => _checkPurchaseStatus()); // Re-checks if they successfully paid
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

  @override
  Widget build(BuildContext context) {
    final isFree = widget.price == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Guide Details'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges (Free vs Premium)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          isFree ? AppTheme.primaryGreen : AppTheme.sacredGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFree ? 'FREE GUIDE' : 'PREMIUM GUIDE',
                      style: TextStyle(
                        color: isFree ? Colors.white : AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 24),

                  // FREE PREVIEW SECTION
                  const Text(
                    "Overview & Summary:",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      widget.description,
                      style: const TextStyle(
                          fontSize: 15, height: 1.6, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // THE ACTION BUTTONS (Reader Mode & Full PDF)
                  if (_hasPurchased) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _openReaderMode,
                        icon: const Icon(Icons.auto_stories,
                            color: Colors.white),
                        label: const Text(
                          "READ INSTANTLY (CHAPTER VIEW)",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(
                              color: AppTheme.primaryBlue, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _openPdf,
                        icon: const Icon(Icons.picture_as_pdf,
                            color: AppTheme.primaryBlue),
                        label: const Text(
                          "DOWNLOAD / VIEW FULL PDF",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _handleUnlockClick,
                        icon: const Icon(Icons.lock_open,
                            color: AppTheme.primaryBlue),
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
