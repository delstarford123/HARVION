import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class SdaHymnAudioService {
  static final SdaHymnAudioService _instance = SdaHymnAudioService._internal();
  factory SdaHymnAudioService() => _instance;
  SdaHymnAudioService._internal();

  final Map<int, double> _downloadProgress = {};
  final Set<int> _activeDownloads = {};

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

    try {
      final url = getOnlineUrl(hymnNumber);
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      request.headers['User-Agent'] = 'HARVION_SDA_App/1.0';

      final response = await client.send(request);

      if (response.statusCode != 200) {
        client.close();
        _activeDownloads.remove(hymnNumber);
        return null;
      }

      final contentLength = response.contentLength ?? 0;
      final file = await getLocalFile(hymnNumber);
      final sink = file.openWrite();

      int receivedBytes = 0;
      await response.stream.listen((chunk) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (contentLength > 0) {
          final progress = receivedBytes / contentLength;
          _downloadProgress[hymnNumber] = progress;
          onProgress?.call(progress);
        }
      }).asFuture();

      await sink.flush();
      await sink.close();
      client.close();

      _downloadProgress[hymnNumber] = 1.0;
      _activeDownloads.remove(hymnNumber);
      onProgress?.call(1.0);

      return file;
    } catch (e) {
      debugPrint('[SdaHymnAudioService] Download failed for Hymn #$hymnNumber: $e');
      _activeDownloads.remove(hymnNumber);
      try {
        final f = await getLocalFile(hymnNumber);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      return null;
    }
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

