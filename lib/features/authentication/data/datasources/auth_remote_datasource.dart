import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_messages.dart';
import '../../domain/models/user_model.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentAuthUser => _auth.currentUser;

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('Login failed');

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw const AuthException('User data not found',
            code: AppErrorCodes.userDataNotFound);
      }

      final userModel = UserModel.fromFirestore(doc);
      if (!userModel.isActive) {
        await _auth.signOut();
        throw const AuthException('Account disabled',
            code: AppErrorCodes.accountDisabled);
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code), code: e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    debugPrint('AuthDatasource.register: starting for $email');

    // Step 1: Create Firebase Auth account.
    final UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('AuthDatasource.register: auth account created uid=${credential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthDatasource.register: FirebaseAuthException ${e.code} — ${e.message}');
      throw AuthException(_mapAuthError(e.code), code: e.code);
    } catch (e) {
      debugPrint('AuthDatasource.register: unexpected auth error — $e');
      throw AuthException('Registration failed: $e');
    }

    final uid = credential.user?.uid;
    if (uid == null) {
      debugPrint('AuthDatasource.register: credential.user is null after creation');
      throw const AuthException('Registration failed: no user returned by Firebase');
    }

    // Step 2: Update display name — non-fatal; use currentUser for fresh ref.
    try {
      await _auth.currentUser?.updateDisplayName(name);
      debugPrint('AuthDatasource.register: display name set');
    } catch (e) {
      debugPrint('AuthDatasource.register: display name update failed (non-fatal) — $e');
    }

    // Step 3: Build the user model.
    final userModel = UserModel(
      uid: uid,
      name: name,
      phone: phone,
      email: email.trim(),
      role: AppConstants.rolePatient,
      isActive: true,
      createdAt: DateTime.now(),
    );

    // Step 4: Write Firestore document. Without it the app signs the user
    // out on the next launch, so roll back the auth account if this fails.
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(userModel.toMap());
      debugPrint('AuthDatasource.register: Firestore document created for uid=$uid');
    } catch (e) {
      debugPrint('AuthDatasource.register: Firestore write failed — $e');
      try {
        await _auth.currentUser?.delete();
      } catch (deleteError) {
        debugPrint('AuthDatasource.register: rollback failed — $deleteError');
        await _auth.signOut();
      }
      throw const AuthException('Profile write failed',
          code: AppErrorCodes.profileSaveFailed);
    }

    // Step 5: Send verification email — non-fatal.
    try {
      await _auth.currentUser?.sendEmailVerification();
      debugPrint('AuthDatasource.register: verification email sent');
    } catch (e) {
      debugPrint('AuthDatasource.register: verification email failed (non-fatal) — $e');
    }

    debugPrint('AuthDatasource.register: completed for uid=$uid');
    return userModel;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code), code: e.code);
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      if (!doc.exists) {
        debugPrint('AuthDatasource: user document not found for uid=${user.uid}, signing out');
        await _auth.signOut();
        return null;
      }
      final model = UserModel.fromFirestore(doc);
      // Auto-login must respect a disabled account, like signIn() does.
      if (!model.isActive) {
        debugPrint('AuthDatasource: account disabled for uid=${user.uid}, signing out');
        await _auth.signOut();
        return null;
      }
      return model;
    } catch (e) {
      debugPrint('AuthDatasource: getCurrentUser error: $e');
      return null;
    }
  }

  Future<void> updateFcmToken(String uid, String token) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'fcmToken': token});
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (profileImage != null) updates['profileImage'] = profileImage;

    if (updates.isNotEmpty) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(updates);
    }

    if (name != null) {
      await _auth.currentUser?.updateDisplayName(name);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw const AuthException('Not authenticated');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code), code: e.code);
    }
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'weak-password':
        return 'Password is too weak';
      case 'requires-recent-login':
        return 'Please re-authenticate to complete this action';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
