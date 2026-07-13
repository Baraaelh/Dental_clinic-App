import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final AuthRemoteDatasource _datasource;

  // Avoids a Firestore round-trip when Firebase re-emits auth state for the
  // same already-loaded user (e.g. on token refresh or hot-restart).
  UserModel? _userCache;

  @override
  Stream<UserModel?> get authStateChanges {
    return _datasource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _userCache = null;
        return null;
      }

      // Return cached model immediately if it is for the same user.
      if (_userCache != null && _userCache!.uid == firebaseUser.uid) {
        return _userCache;
      }

      // Try up to 2 times. Each attempt carries a 15-second internal timeout
      // (AppConstants.firestoreTimeout), giving ~30 seconds total before the
      // fallback kicks in.
      UserModel? model;
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          model = await _datasource.getCurrentUser();
        } catch (e) {
          debugPrint('AuthRepository: attempt $attempt error for uid=${firebaseUser.uid}: $e');
        }
        if (model != null) break;
        if (attempt < 2) {
          debugPrint('AuthRepository: attempt $attempt failed for uid=${firebaseUser.uid}, retrying…');
        }
      }

      if (model != null) {
        _userCache = model;
        return model;
      }

      // If the Firebase Auth session is still active the failures were caused by
      // a network/timeout issue, not a missing document. Return a minimal
      // fallback so the router sends the user to /home instead of leaving them
      // on the splash screen or redirecting to login.
      if (_datasource.currentAuthUser != null) {
        debugPrint('AuthRepository: Firestore unreachable — using patient fallback for uid=${firebaseUser.uid}');
        final fallback = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          phone: '',
          role: AppConstants.rolePatient,
          isActive: true,
        );
        _userCache = fallback;
        return fallback;
      }

      // Auth session ended during fetch (doc-not-found triggered a sign-out).
      _userCache = null;
      return null;
    });
  }

  @override
  Future<UserModel> signIn({required String email, required String password}) {
    return _datasource.signIn(email: email, password: password);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return _datasource.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    _userCache = null;
    await _datasource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _datasource.sendPasswordResetEmail(email);

  @override
  Future<UserModel?> getCurrentUser() => _datasource.getCurrentUser();

  @override
  Future<void> updateFcmToken(String uid, String token) =>
      _datasource.updateFcmToken(uid, token);

  @override
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? profileImage,
  }) =>
      _datasource.updateProfile(
        uid: uid,
        name: name,
        phone: phone,
        profileImage: profileImage,
      );

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _datasource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  @override
  Future<void> sendEmailVerification() => _datasource.sendEmailVerification();

  @override
  bool get isEmailVerified => _datasource.isEmailVerified;
}
