import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../book_model.dart';

class BookCacheService {
  static final BookCacheService _instance = BookCacheService._internal();
  factory BookCacheService() => _instance;
  BookCacheService._internal();

  final Map<String, double> downloadProgress = {};
  final Set<String> _activeDownloads = {};

  /// Get the directory where SOP books and PDFs are stored locally
  Future<Directory> _getBooksDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${appDir.path}/sop_books');
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }
    return booksDir;
  }

  /// Get the local file path for a book
  Future<File> getLocalBookFile(String bookId) async {
    final dir = await _getBooksDirectory();
    final cleanId = bookId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return File('${dir.path}/$cleanId.pdf');
  }

  /// Check if the book's PDF is already downloaded and cached locally
  Future<bool> isBookCached(String bookId) async {
    try {
      final file = await getLocalBookFile(bookId);
      final exists = await file.exists();
      if (exists && await file.length() > 1000) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Download a book's PDF file and cache it locally with progress callbacks
  Future<File?> downloadAndCacheBook(
    Book book, {
    void Function(double progress)? onProgress,
  }) async {
    if (book.pdfUrl.isEmpty || !book.pdfUrl.startsWith('http')) {
      return null;
    }

    final localFile = await getLocalBookFile(book.id);
    if (await localFile.exists() && await localFile.length() > 5000) {
      onProgress?.call(1.0);
      return localFile;
    }

    if (_activeDownloads.contains(book.id)) {
      // Wait for active download to finish
      int waited = 0;
      while (_activeDownloads.contains(book.id) && waited < 40) {
        await Future.delayed(const Duration(milliseconds: 500));
        waited++;
      }
      if (await localFile.exists()) return localFile;
    }

    _activeDownloads.add(book.id);

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(book.pdfUrl));
      request.headers['User-Agent'] = 'Mozilla/5.0 (Harvion SDA Ministry App)';

      final response = await client.send(request).timeout(const Duration(seconds: 45));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final totalBytes = response.contentLength ?? 0;
        int receivedBytes = 0;
        final List<int> bytes = [];

        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0) {
            final p = receivedBytes / totalBytes;
            downloadProgress[book.id] = p;
            onProgress?.call(p);
          }
        }

        // Validate that we didn't receive an HTML error page instead of PDF bytes
        final header = bytes.length > 5 ? String.fromCharCodes(bytes.sublist(0, 5)) : '';
        if (header.startsWith('%PDF') || bytes.length > 50000) {
          await localFile.writeAsBytes(bytes, flush: true);
          downloadProgress[book.id] = 1.0;
          onProgress?.call(1.0);
          return localFile;
        } else {
          debugPrint("Downloaded content for ${book.title} was not a valid PDF binary.");
          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error downloading book ${book.title}: $e");
      return null;
    } finally {
      _activeDownloads.remove(book.id);
    }
  }

  /// Automatically preload core Spirit of Prophecy books in the background
  void preloadCoreSopBooks(List<Book> books) {
    Future.microtask(() async {
      for (final book in books) {
        try {
          final isCached = await isBookCached(book.id);
          if (!isCached && book.pdfUrl.startsWith('http') && book.pdfUrl.endsWith('.pdf')) {
            debugPrint("Preloading SOP book in background: ${book.title}");
            await downloadAndCacheBook(book);
          }
        } catch (e) {
          debugPrint("Preload error for ${book.title}: $e");
        }
      }
    });
  }

  /// Delete cached book if needed
  Future<void> clearBookCache(String bookId) async {
    try {
      final file = await getLocalBookFile(bookId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

