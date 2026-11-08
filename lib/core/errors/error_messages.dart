import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import 'app_exception.dart';

/// Error codes used by the app's own exceptions (see datasources).
class AppErrorCodes {
  const AppErrorCodes._();

  static const slotUnavailable = 'slot-unavailable';
  static const alreadyReviewed = 'already-reviewed';
  static const reviewNotAllowed = 'review-not-allowed';
  static const profileSaveFailed = 'profile-save-failed';
  static const accountDisabled = 'account-disabled';
  static const userDataNotFound = 'user-data-not-found';
}

/// Turns any error into a short, translated message for the user.
/// Technical details are logged, never shown.
String localizedErrorMessage(AppLocalizations l10n, Object error) {
  final code = switch (error) {
    AppException(:final code) => code,
    FirebaseException(:final code) => code,
    _ => null,
  };

  switch (code) {
    case AppErrorCodes.slotUnavailable:
      return l10n.slotAlreadyBooked;
    case AppErrorCodes.alreadyReviewed:
      return l10n.alreadyReviewed;
    case AppErrorCodes.reviewNotAllowed:
      return l10n.cannotReview;
    case AppErrorCodes.profileSaveFailed:
      return l10n.errorProfileSaveFailed;
    case AppErrorCodes.accountDisabled:
    case 'user-disabled':
      return l10n.errorAccountDisabled;
    case AppErrorCodes.userDataNotFound:
      return l10n.errorUserDataNotFound;
    case 'user-not-found':
      return l10n.errorUserNotFound;
    case 'wrong-password':
      return l10n.errorWrongPassword;
    case 'invalid-credential':
      return l10n.errorInvalidCredential;
    case 'email-already-in-use':
      return l10n.errorEmailInUse;
    case 'invalid-email':
      return l10n.errorInvalidEmail;
    case 'too-many-requests':
      return l10n.errorTooManyRequests;
    case 'weak-password':
      return l10n.errorWeakPassword;
    case 'requires-recent-login':
      return l10n.errorRequiresRecentLogin;
    case 'network-request-failed':
    case 'unavailable':
      return l10n.noInternetConnection;
    case 'permission-denied':
      return l10n.errorPermissionDenied;
  }

  if (error is NotFoundException) return l10n.errorNotFound;

  // ServerException wraps the original Firebase error in its message.
  final text = error.toString();
  if (text.contains('permission-denied')) return l10n.errorPermissionDenied;
  if (text.contains('unavailable') || text.contains('network')) {
    return l10n.noInternetConnection;
  }

  debugPrint('Unmapped error shown to user: $error');
  return l10n.somethingWentWrong;
}

extension ErrorMessageContext on BuildContext {
  /// `context.errorMessage(e)` → translated message for [error].
  String errorMessage(Object error) =>
      localizedErrorMessage(AppLocalizations.of(this), error);
}
