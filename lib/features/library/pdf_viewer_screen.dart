import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'book_model.dart';
import 'services/book_cache_service.dart';
import 'services/online_reader_service.dart';
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

    final url = widget.book.effectiveOnlineUrl;

    // Check if this is a web link (e.g., egwwritings toc, online reader or gutenberg ebook page)
    if (url.contains('egwwritings.org') || url.contains('/toc') || url.contains('ebooks/') || (!url.endsWith('.pdf') && !url.contains('.pdf?'))) {
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

      // If it's an online publication rather than a downloadable PDF file, present options immediately
      if (_isHtmlSource) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'This title is an official online digital publication. You can read it online on EGW Writings or offline in Harvion Chapter Reader.';
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
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("PDF Load Error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Could not load PDF document. Please read online or switch to Chapter Mode.';
        });
      }
    }
  }

  Future<void> _launchOnlineUrl() async {
    await OnlineReaderService.openOnlineBook(
      context,
      widget.book.effectiveOnlineUrl,
      title: widget.book.title,
    );
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
          IconButton(
            icon: const Icon(Icons.public),
            tooltip: 'Read Online (EGW Writings)',
            onPressed: _launchOnlineUrl,
          ),
          IconButton(
            icon: const Icon(Icons.auto_stories),
            tooltip: 'Chapter Reader Mode',
            onPressed: _openReaderMode,
          ),
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
                          _errorMessage = details.description;
                        });
                      }
                    },
                  )
                : widget.book.pdfUrl.endsWith('.pdf')
                    ? SfPdfViewer.network(
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
                              _errorMessage = details.description;
                            });
                          }
                        },
                      )
                    : const SizedBox.shrink(),

          // 2. Loading Overlay with Progress
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _downloadProgress > 0 && _downloadProgress < 1.0
                          ? "Downloading (${(_downloadProgress * 100).toInt()}%)..."
                          : "Preparing Reader...",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _downloadProgress > 0 ? _downloadProgress : null,
                          backgroundColor: Colors.grey.shade200,
                          color: AppTheme.sacredGold,
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Fallback View & Options
          if (_hasError)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
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
                              : 'This Spirit of Prophecy publication is available for reading.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.public, color: AppTheme.sacredGold, size: 20),
                            label: const Text(
                              'READ ONLINE (OFFICIAL EGW WRITINGS)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: _launchOnlineUrl,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryGreen,
                              side: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.auto_stories, size: 20),
                            label: const Text(
                              'READ OFFLINE (CHAPTER MODE)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: _openReaderMode,
                          ),
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
