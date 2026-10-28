import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart'; // 🚀 Added sharing
import '../../core/theme.dart';
import 'book_model.dart';

class PdfViewerScreen extends StatefulWidget {
  final Book book;

  const PdfViewerScreen({super.key, required this.book});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();

  bool _isLoading = true;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.book.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 🚀 The Share Button - uses the exact same logic as your library cards!
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Guide',
            onPressed: () {
              Share.share(widget.book.generateShareText());
            },
          ),
        ],
      ),
      // We use a Stack so we can put the Loading Spinner ON TOP of the PDF viewer
      body: Stack(
        children: [
          // 1. The Actual PDF Viewer
          SfPdfViewer.network(
            widget.book.pdfUrl,
            key: _pdfViewerKey,
            controller: _pdfViewerController,
            canShowScrollHead:
                false, // Removes the ugly default scrollbar header

            // Triggered when the download finishes
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _isLoading = false;
                _hasError = false;
              });
            },

            // Triggered if the internet fails or URL is broken
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            },
          ),

          // 2. The Loading Spinner
          if (_isLoading && !_hasError)
            Container(
              color: AppTheme.backgroundLight, // Hides the blank white screen
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryGreen),
                    SizedBox(height: 16),
                    Text(
                      'Downloading Guide...\nPlease wait.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. The Error Screen (If offline)
          if (_hasError)
            Container(
              color: AppTheme.backgroundLight,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Network Error',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load "${widget.book.title}".\nPlease check your internet connection.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Force a reload by toggling the loading state
                        setState(() {
                          _isLoading = true;
                          _hasError = false;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
