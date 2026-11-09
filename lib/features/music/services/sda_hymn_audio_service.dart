import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Real-time status model for batch downloads
class BatchDownloadStatus {
  final bool isRunning;
  final bool isPaused;
  final int completed;
  final int total;
  final int currentHymnNumber;
  final String currentHymnTitle;
  final double currentHymnProgress;
  final double overallProgress;
  final String message;

  const BatchDownloadStatus({
    this.isRunning = false,
    this.isPaused = false,
    this.completed = 0,
    this.total = 695,
    this.currentHymnNumber = 0,
    this.currentHymnTitle = '',
    this.currentHymnProgress = 0.0,
    this.overallProgress = 0.0,
    this.message = '',
  });

  BatchDownloadStatus copyWith({
    bool? isRunning,
    bool? isPaused,
    int? completed,
    int? total,
    int? currentHymnNumber,
    String? currentHymnTitle,
    double? currentHymnProgress,
    double? overallProgress,
    String? message,
  }) {
    return BatchDownloadStatus(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      completed: completed ?? this.completed,
      total: total ?? this.total,
      currentHymnNumber: currentHymnNumber ?? this.currentHymnNumber,
      currentHymnTitle: currentHymnTitle ?? this.currentHymnTitle,
      currentHymnProgress: currentHymnProgress ?? this.currentHymnProgress,
      overallProgress: overallProgress ?? this.overallProgress,
      message: message ?? this.message,
    );
  }
}

class SdaHymnAudioService {
  static final SdaHymnAudioService _instance = SdaHymnAudioService._internal();
  factory SdaHymnAudioService() => _instance;
  SdaHymnAudioService._internal();

  final Map<int, double> _downloadProgress = {};
  final Set<int> _activeDownloads = {};

  // Batch download state
  final StreamController<BatchDownloadStatus> _batchStatusController =
      StreamController<BatchDownloadStatus>.broadcast();
  Stream<BatchDownloadStatus> get batchStatusStream => _batchStatusController.stream;

  BatchDownloadStatus _currentBatchStatus = const BatchDownloadStatus();
  BatchDownloadStatus get currentBatchStatus => _currentBatchStatus;

  bool _isBatchCancelled = false;
  bool _isBatchPaused = false;

  double getProgress(int hymnNumber) => _downloadProgress[hymnNumber] ?? 0.0;
  bool isDownloading(int hymnNumber) => _activeDownloads.contains(hymnNumber);

  /// Directory where offline piano MP3 files are stored
  Future<Directory> _getHymnsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final hymnsDir = Directory('${appDir.path}/sda_hymns');
    if (!await hymnsDir.exists()) {
      await hymnsDir.create(recursive: true);
    }
    return hymnsDir;
  }

  /// Formatted filename, e.g. '108.mp3'
  String _getFileName(int hymnNumber) {
    return '${hymnNumber.toString().padLeft(3, '0')}.mp3';
  }

  /// Get the local File object for a hymn
  Future<File> getLocalFile(int hymnNumber) async {
    final dir = await _getHymnsDirectory();
    return File('${dir.path}/${_getFileName(hymnNumber)}');
  }

  /// Get verified online piano audio streaming URL
  String getOnlineUrl(int hymnNumber) {
    final pad = hymnNumber.toString().padLeft(3, '0');
    return 'https://hymnal.pro/sda-hymnal/mp3/$pad.mp3';
  }

  /// Check if hymn piano audio is downloaded and cached offline
  Future<bool> isHymnDownloaded(int hymnNumber) async {
    try {
      final file = await getLocalFile(hymnNumber);
      if (await file.exists()) {
        final length = await file.length();
        if (length > 2000) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Retrieve all downloaded hymn numbers as a set for instant UI badges
  Future<Set<int>> getDownloadedHymnNumbers() async {
    final downloaded = <int>{};
    try {
      final dir = await _getHymnsDirectory();
      if (!await dir.exists()) return downloaded;

      final entities = dir.listSync();
      for (final e in entities) {
        if (e is File && e.path.endsWith('.mp3')) {
          final baseName = e.uri.pathSegments.last.replaceAll('.mp3', '');
          final num = int.tryParse(baseName);
          if (num != null && e.lengthSync() > 2000) {
            downloaded.add(num);
          }
        }
      }
    } catch (e) {
      debugPrint('[SdaHymnAudioService] Error reading downloaded list: $e');
    }
    return downloaded;
  }

  /// Download a hymn's piano track with real-time progress callbacks
  Future<File?> downloadHymn(
    int hymnNumber, {
    void Function(double progress)? onProgress,
  }) async {
    if (_activeDownloads.contains(hymnNumber)) {
      return null;
    }

    _activeDownloads.add(hymnNumber);
    _downloadProgress[hymnNumber] = 0.0;

    for (int attempt = 1; attempt <= 3; attempt++) {
      http.Client? client;
      IOSink? sink;
      try {
        final url = getOnlineUrl(hymnNumber);
        client = http.Client();
        final request = http.Request('GET', Uri.parse(url));
        request.headers['User-Agent'] = 'HARVION_SDA_App/1.0';

        final response = await client.send(request);

        if (response.statusCode != 200) {
          client.close();
          if (attempt < 3) {
            await Future.delayed(const Duration(milliseconds: 600));
            continue;
          }
          _activeDownloads.remove(hymnNumber);
          return null;
        }

        final contentLength = response.contentLength ?? 0;
        final file = await getLocalFile(hymnNumber);
        sink = file.openWrite();

        int receivedBytes = 0;
        await response.stream.listen((chunk) {
          sink?.add(chunk);
          receivedBytes += chunk.length;
          if (contentLength > 0) {
            final progress = receivedBytes / contentLength;
            _downloadProgress[hymnNumber] = progress;
            onProgress?.call(progress);
          }
        }).asFuture();

        await sink.flush();
        await sink.close();
        sink = null;
        client.close();

        // Validate downloaded file size
        if (await file.exists() && await file.length() > 2000) {
          _downloadProgress[hymnNumber] = 1.0;
          _activeDownloads.remove(hymnNumber);
          onProgress?.call(1.0);
          return file;
        } else {
          throw Exception('Incomplete file downloaded');
        }
      } catch (e) {
        try {
          await sink?.close();
        } catch (_) {}
        client?.close();

        if (attempt < 3) {
          debugPrint('[SdaHymnAudioService] Retry $attempt for Hymn #$hymnNumber due to: $e');
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        } else {
          debugPrint('[SdaHymnAudioService] Download failed after 3 attempts for Hymn #$hymnNumber: $e');
          _activeDownloads.remove(hymnNumber);
          try {
            final f = await getLocalFile(hymnNumber);
            if (await f.exists()) await f.delete();
          } catch (_) {}
          return null;
        }
      }
    }
    _activeDownloads.remove(hymnNumber);
    return null;
  }

  // ==========================================
  // 🚀 BATCH DOWNLOAD ALL 695 HYMNS
  // ==========================================

  void _emitBatchStatus(BatchDownloadStatus status) {
    _currentBatchStatus = status;
    _batchStatusController.add(status);
  }

  /// Pause current batch download
  void pauseBatchDownload() {
    _isBatchPaused = true;
    _emitBatchStatus(_currentBatchStatus.copyWith(
      isPaused: true,
      message: 'Download paused by user.',
    ));
  }

  /// Resume paused batch download
  void resumeBatchDownload() {
    _isBatchPaused = false;
    _emitBatchStatus(_currentBatchStatus.copyWith(
      isPaused: false,
      message: 'Resuming download...',
    ));
  }

  /// Cancel batch download
  void cancelBatchDownload() {
    _isBatchCancelled = true;
    _isBatchPaused = false;
    _emitBatchStatus(_currentBatchStatus.copyWith(
      isRunning: false,
      isPaused: false,
      message: 'Batch download cancelled.',
    ));
  }

  /// Start downloading all remaining hymns (1 to 695)
  Future<void> startBatchDownload({
    int totalHymns = 695,
    Map<int, String>? hymnTitles,
  }) async {
    if (_currentBatchStatus.isRunning && !_currentBatchStatus.isPaused) {
      return;
    }

    _isBatchCancelled = false;
    _isBatchPaused = false;

    final downloadedSet = await getDownloadedHymnNumbers();
    final toDownload = <int>[];
    for (int i = 1; i <= totalHymns; i++) {
      if (!downloadedSet.contains(i)) {
        toDownload.add(i);
      }
    }

    int completedCount = downloadedSet.length;
    _emitBatchStatus(BatchDownloadStatus(
      isRunning: true,
      isPaused: false,
      completed: completedCount,
      total: totalHymns,
      currentHymnNumber: toDownload.isNotEmpty ? toDownload.first : 0,
      currentHymnTitle: hymnTitles?[toDownload.isNotEmpty ? toDownload.first : 0] ?? '',
      overallProgress: completedCount / totalHymns,
      message: 'Starting offline piano pack download...',
    ));

    if (toDownload.isEmpty) {
      _emitBatchStatus(BatchDownloadStatus(
        isRunning: false,
        isPaused: false,
        completed: totalHymns,
        total: totalHymns,
        overallProgress: 1.0,
        message: 'All $totalHymns hymns are already downloaded!',
      ));
      return;
    }

    for (int i = 0; i < toDownload.length; i++) {
      if (_isBatchCancelled) {
        break;
      }

      // Check if paused
      while (_isBatchPaused && !_isBatchCancelled) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (_isBatchCancelled) {
        break;
      }

      final hymnNum = toDownload[i];
      final title = hymnTitles?[hymnNum] ?? 'Hymn #$hymnNum';

      _emitBatchStatus(_currentBatchStatus.copyWith(
        isRunning: true,
        currentHymnNumber: hymnNum,
        currentHymnTitle: title,
        currentHymnProgress: 0.0,
        overallProgress: completedCount / totalHymns,
        message: 'Downloading #$hymnNum: $title',
      ));

      final file = await downloadHymn(
        hymnNum,
        onProgress: (p) {
          _emitBatchStatus(_currentBatchStatus.copyWith(
            currentHymnProgress: p,
            overallProgress: (completedCount + p) / totalHymns,
          ));
        },
      );

      if (file != null) {
        completedCount++;
      }

      _emitBatchStatus(_currentBatchStatus.copyWith(
        completed: completedCount,
        overallProgress: completedCount / totalHymns,
      ));

      // Friendly delay between tracks to respect CDN
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _emitBatchStatus(BatchDownloadStatus(
      isRunning: false,
      isPaused: false,
      completed: completedCount,
      total: totalHymns,
      overallProgress: completedCount / totalHymns,
      message: completedCount >= totalHymns
          ? '✓ Complete! All $totalHymns hymn piano tracks are saved offline.'
          : 'Download session finished ($completedCount of $totalHymns saved).',
    ));
  }

  /// Delete cached hymn to free up local space if desired
  Future<bool> deleteHymn(int hymnNumber) async {
    try {
      final file = await getLocalFile(hymnNumber);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      debugPrint('[SdaHymnAudioService] Delete error: $e');
    }
    return false;
  }
}
