import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  /// Explicitly target user storage bucket: gs://vine-3e4ab.firebasestorage.app
  static const String bucketName = 'vine-3e4ab.firebasestorage.app';

  FirebaseStorage get _storage => FirebaseStorage.instanceFor(bucket: bucketName);

  /// Uploads a book cover image and returns its download URL
  Future<String> uploadBookCover({
    File? file,
    Uint8List? bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';
    final ref = _storage.ref().child('books/covers/$uniqueName');

    return _uploadFileOrBytes(
      ref: ref,
      file: file,
      bytes: bytes,
      contentType: 'image/jpeg',
      onProgress: onProgress,
    );
  }

  /// Uploads an interior preview image of a book
  Future<String> uploadBookPreviewImage({
    File? file,
    Uint8List? bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';
    final ref = _storage.ref().child('books/previews/$uniqueName');

    return _uploadFileOrBytes(
      ref: ref,
      file: file,
      bytes: bytes,
      contentType: 'image/jpeg',
      onProgress: onProgress,
    );
  }

  /// Uploads a soft-copy PDF file for Literature Evangelism
  Future<String> uploadBookPdf({
    File? file,
    Uint8List? bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';
    final ref = _storage.ref().child('books/soft_copies/$uniqueName');

    return _uploadFileOrBytes(
      ref: ref,
      file: file,
      bytes: bytes,
      contentType: 'application/pdf',
      onProgress: onProgress,
    );
  }

  /// Uploads an image submitted by a seller requesting to sell books
  Future<String> uploadSellerBookImage({
    File? file,
    Uint8List? bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';
    final ref = _storage.ref().child('seller_requests/$uniqueName');

    return _uploadFileOrBytes(
      ref: ref,
      file: file,
      bytes: bytes,
      contentType: 'image/jpeg',
      onProgress: onProgress,
    );
  }

  /// Internal helper to handle both mobile (File) and web (Uint8List)
  Future<String> _uploadFileOrBytes({
    required Reference ref,
    File? file,
    Uint8List? bytes,
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final SettableMetadata metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'bucket': bucketName,
        },
      );

      UploadTask uploadTask;
      if (kIsWeb || bytes != null) {
        if (bytes == null && file != null) {
          bytes = await file.readAsBytes();
        }
        if (bytes == null) {
          throw Exception('No data provided to upload to Firebase Storage.');
        }
        uploadTask = ref.putData(bytes, metadata);
      } else {
        if (file == null) {
          throw Exception('No file provided for native upload.');
        }
        uploadTask = ref.putFile(file, metadata);
      }

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress?.call(progress);
        }
      });

      final TaskSnapshot completedSnapshot = await uploadTask;
      final String downloadUrl = await completedSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('[FirebaseStorageService] Upload failed: $e');
      rethrow;
    }
  }
}
