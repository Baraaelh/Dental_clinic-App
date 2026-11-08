import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/models/notification_model.dart';

/// Title and body of [n] in the current app language when it is a known
/// appointment-status notification; otherwise the stored text.
({String title, String body}) localizedNotificationText(
    AppLocalizations l10n, NotificationModel n) {
  switch (n.type) {
    case AppConstants.statusApproved:
      return (
        title: l10n.notificationTitleApproved,
        body: l10n.notificationApproved,
      );
    case AppConstants.statusRejected:
      return (
        title: l10n.notificationTitleRejected,
        body: l10n.notificationRejected,
      );
    case AppConstants.statusCancelled:
      return (
        title: l10n.notificationTitleCancelled,
        body: l10n.notificationCancelled,
      );
    case AppConstants.statusCompleted:
      return (
        title: l10n.notificationTitleCompleted,
        body: l10n.notificationCompleted,
      );
    default:
      return (title: n.title, body: n.body);
  }
}
