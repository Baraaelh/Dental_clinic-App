import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);

class ProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    File? imageFile,
  }) async {
    state = const AsyncLoading();
    try {
      String? imageUrl;

      if (imageFile != null) {
        final path = StorageService.instance.generatePath(
          AppConstants.storageProfileImages,
          uid,
          'jpg',
        );
        imageUrl =
            await StorageService.instance.uploadFile(file: imageFile, path: path);
      }

      await ref.read(authRepositoryProvider).updateProfile(
            uid: uid,
            name: name,
            phone: phone,
            profileImage: imageUrl,
          );

      // currentUserProvider is now derived from authStateProvider — it will
      // reflect the update the next time the auth stream re-emits. No manual
      // state write needed.

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
