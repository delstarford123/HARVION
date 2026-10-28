import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import 'book_model.dart';
import 'services/book_cache_service.dart';
import 'sop_book_reader_screen.dart';

class PdfViewerScreen extends StatefulWidget {
  final Book book;

  const PdfViewerScreen({super.key, required this.book});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();

  File? _localFile;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  double _downloadProgress = 0.0;
  bool _isHtmlSource = false;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _downloadProgress = 0.0;
    });

    final url = widget.book.pdfUrl.trim();

    // Check if this is a web link (e.g., egwwritings toc or gutenberg ebook page)
    if (url.contains('/toc') || url.contains('ebooks/') || (!url.endsWith('.pdf') && !url.contains('.pdf?'))) {
      _isHtmlSource = true;
    }

    try {
      // 1. Check if already cached on disk
      final isCached = await BookCacheService().isBookCached(widget.book.id);
      if (isCached) {
        final file = await BookCacheService().getLocalBookFile(widget.book.id);
        if (await file.exists() && await file.length() > 5000) {
          if (mounted) {
            setState(() {
              _localFile = file;
              _isLoading = false;
            });
          }
          return;
        }
      }

      // If it's an HTML webpage rather than a direct PDF stream, offer Reader Mode immediately
      if (_isHtmlSource) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'This title is an online library publication. You can read it instantly in Harvion Chapter Reader or open it in your browser.';
          });
        }
        return;
      }

      // 2. Download and cache PDF with progress
      final downloadedFile = await BookCacheService().downloadAndCacheBook(
        widget.book,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
            });
          }
        },
      );

      if (downloadedFile != null && await downloadedFile.exists()) {
        if (mounted) {
          setState(() {
            _localFile = downloadedFile;
            _isLoading = false;
          });
        }
      } else {
        // Fallback to direct network rendering if download cache couldn't save file
        if (mounted) {
          setState(() {
            _localFile = null;
            _isLoading = false; // SfPdfViewer.network will handle loading state
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Could not download PDF. Please switch to Harvion Reader Mode or verify network connection.';
        });
      }
    }
  }

  Future<void> _launchOnlineUrl() async {
    final uri = Uri.tryParse(widget.book.pdfUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open external link.')),
        );
      }
    }
  }

  void _openReaderMode() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SopBookReaderScreen(book: widget.book),
      ),
    );
  }

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
          // Quick Switch to Fast Reader Mode
          IconButton(
            icon: const Icon(Icons.auto_stories),
            tooltip: 'Chapter Reader Mode',
            onPressed: _openReaderMode,
          ),
          // Share Button
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Guide',
            onPressed: () {
              Share.share(widget.book.generateShareText());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. The Actual PDF Viewer (File based if cached, otherwise Network)
          if (!_hasError)
            _localFile != null
                ? SfPdfViewer.file(
                    _localFile!,
                    key: _pdfViewerKey,
                    controller: _pdfViewerController,
                    canShowScrollHead: false,
                    onDocumentLoaded: (details) {
                      if (mounted) setState(() => _isLoading = false);
                    },
                    onDocumentLoadFailed: (details) {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                          _hasError = true;
                          _errorMessage = 'Document could not be displayed. You can read it in Reader Mode.';
                        });
                      }
                    },
                  )
                : SfPdfViewer.network(
                    widget.book.pdfUrl,
                    key: _pdfViewerKey,
                    controller: _pdfViewerController,
                    canShowScrollHead: false,
                    onDocumentLoaded: (details) {
                      if (mounted) setState(() => _isLoading = false);
                    },
                    onDocumentLoadFailed: (details) {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                          _hasError = true;
                          _errorMessage = 'Network stream failed. Use Harvion Chapter Reader for 100% offline reading.';
                        });
                      }
                    },
                  ),

          // 2. Loading / Downloading progress overlay
          if (_isLoading && !_hasError)
            Container(
              color: AppTheme.backgroundLight,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primaryGreen),
                      const SizedBox(height: 20),
                      Text(
                        _downloadProgress > 0
                            ? 'Downloading Guide (${(_downloadProgress * 100).toInt()}%)...'
                            : 'Preparing Guide for Instant Reading...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (_downloadProgress > 0) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _downloadProgress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                            minHeight: 6,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(color: AppTheme.primaryBlue),
                        ),
                        onPressed: _openReaderMode,
                        icon: const Icon(Icons.auto_stories, size: 18),
                        label: const Text('Switch to Offline Reader Now'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 3. Fallback & Reader Option Card (If HTML or Error)
          if (_hasError)
            Container(
              color: AppTheme.backgroundLight,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.menu_book, color: AppTheme.primaryGreen, size: 48),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.book.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage.isNotEmpty
                              ? _errorMessage
                              : 'Fast offline reading is available for this Spirit of Prophecy publication.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.auto_stories, size: 20),
                            label: const Text(
                              'READ INSTANTLY (CHAPTER MODE)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: _openReaderMode,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryBlue,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.public, size: 16),
                                label: const Text('Open Online', style: TextStyle(fontSize: 12)),
                                onPressed: _launchOnlineUrl,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryBlue,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Retry', style: TextStyle(fontSize: 12)),
                                onPressed: _loadBook,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
