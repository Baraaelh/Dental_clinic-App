import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../errors/app_exception.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();

  final _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required File file,
    required String path,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      // Storage rules only accept images, so send the content type.
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: _contentTypeFor(path)),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Upload failed', code: e.code);
    } catch (e) {
      throw ServerException('Failed to upload file: $e');
    }
  }

  Future<String> uploadBytes({
    required Uint8List bytes,
    required String path,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(contentType: contentType);
      await ref.putData(bytes, metadata);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Upload failed', code: e.code);
    }
  }

  /// Best effort: never throws (e.g. for external URLs or missing files).
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Failed to delete file: $e');
    }
  }

  static String _contentTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  String generatePath(String folder, String uid, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$folder/${uid}_$timestamp.$extension';
  }
}
