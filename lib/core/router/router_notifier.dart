import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/domain/models/user_model.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';

final routerNotifierProvider =
    NotifierProvider<RouterNotifier, UserModel?>(RouterNotifier.new);

class RouterNotifier extends Notifier<UserModel?> implements Listenable {
  VoidCallback? _routerListener;

  // Tracks Firebase Auth session without touching Firestore.
  bool _firebaseLoggedIn = false;

  @override
  UserModel? build() {
    // Read the locally-persisted Firebase Auth state synchronously.
    // No network call — uses local storage set by Firebase.initializeApp().
    _firebaseLoggedIn = FirebaseAuth.instance.currentUser != null;
    debugPrint(
      'RouterNotifier: build() '
      'loggedIn=$_firebaseLoggedIn uid=${FirebaseAuth.instance.currentUser?.uid}',
    );

    // Keep _firebaseLoggedIn in sync for sign-in / sign-out / register.
    // Firebase fires this before any Firestore write completes.
    final authSub = FirebaseAuth.instance.authStateChanges().listen(
      (firebaseUser) {
        final nowLoggedIn = firebaseUser != null;
        if (nowLoggedIn != _firebaseLoggedIn) {
          _firebaseLoggedIn = nowLoggedIn;
          debugPrint(
            'RouterNotifier: Firebase auth changed '
            'loggedIn=$_firebaseLoggedIn uid=${firebaseUser?.uid}',
          );
          _routerListener?.call();
        }
      },
    );
    ref.onDispose(() => authSub.cancel());

    // Load full Firestore profile in the background.
    // When it arrives the router re-evaluates (e.g. admin redirect).
    ref.listen<AsyncValue<UserModel?>>(authStateProvider, (_, next) {
      final user = next.valueOrNull;
      if (user != null) {
        _firebaseLoggedIn = true;
      } else if (next is AsyncData<UserModel?>) {
        // Explicit null from Firestore = user is signed out.
        _firebaseLoggedIn = false;
      }
      state = user;
      _routerListener?.call();
    });

    // currentUser is null until Firestore delivers the profile in the background.
    return null;
  }

  @override
  void addListener(VoidCallback listener) => _routerListener = listener;

  @override
  void removeListener(VoidCallback listener) => _routerListener = null;

  UserModel? get currentUser => state;

  /// True as soon as Firebase Auth confirms a session — never blocks on Firestore.
  bool get isAuthenticated => _firebaseLoggedIn;

  bool get isAdmin => currentUser?.isAdmin ?? false;
  bool get isPatient => currentUser?.isPatient ?? false;
}
