import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/fcm_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthRemoteDatasource());
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Derived from authStateProvider so it's always in sync — even for returning users
// who are re-authenticated automatically without calling signIn().
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  late AuthRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(authRepositoryProvider);
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await _repository.signIn(email: email, password: password);

      final prefs = ref.read(sharedPreferencesProvider);
      if (rememberMe) {
        await prefs.setBool(AppConstants.rememberMeKey, true);
        await prefs.setString(AppConstants.savedEmailKey, email);
      } else {
        await prefs.remove(AppConstants.rememberMeKey);
        await prefs.remove(AppConstants.savedEmailKey);
      }

      final fcmToken = await FcmService.instance.getToken();
      if (fcmToken != null) {
        await _repository.updateFcmToken(user.uid, fcmToken);
      }

      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      final fcmToken = await FcmService.instance.getToken();
      if (fcmToken != null) {
        await _repository.updateFcmToken(user.uid, fcmToken);
      }

      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _repository.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    try {
      await _repository.sendPasswordResetEmail(email);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.updateProfile(
        uid: uid,
        name: name,
        phone: phone,
        profileImage: profileImage,
      );
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
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  ({bool rememberMe, String savedEmail}) getSavedCredentials() {
    final prefs = ref.read(sharedPreferencesProvider);
    final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;
    final savedEmail = prefs.getString(AppConstants.savedEmailKey) ?? '';
    return (rememberMe: rememberMe, savedEmail: savedEmail);
  }
}
