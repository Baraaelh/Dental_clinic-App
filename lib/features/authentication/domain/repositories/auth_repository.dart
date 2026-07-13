import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<UserModel?> getCurrentUser();

  Future<void> updateFcmToken(String uid, String token);

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? profileImage,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> sendEmailVerification();

  bool get isEmailVerified;
}
