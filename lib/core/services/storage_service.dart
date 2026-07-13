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
      final uploadTask = ref.putFile(file);

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

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } on FirebaseException catch (e) {
      debugPrint('Failed to delete file: ${e.message}');
    }
  }

  String generatePath(String folder, String uid, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$folder/${uid}_$timestamp.$extension';
  }
}
