import '../../l10n/app_localizations.dart';
import '../constants/app_constants.dart';

/// Translated label for an appointment status stored in Firestore
/// (statuses are stored in English, e.g. "Pending").
String appointmentStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case AppConstants.statusPending:
      return l10n.pending;
    case AppConstants.statusApproved:
      return l10n.approved;
    case AppConstants.statusRejected:
      return l10n.rejected;
    case AppConstants.statusCompleted:
      return l10n.completed;
    case AppConstants.statusCancelled:
      return l10n.cancelled;
    default:
      return status;
  }
}

/// Translated weekday name for the English names stored in `workingDays`.
/// Also accepts 3-letter names such as "Mon".
String weekdayLabel(AppLocalizations l10n, String day) {
  final key = day.trim().toLowerCase();
  switch (key.length < 3 ? key : key.substring(0, 3)) {
    case 'mon':
      return l10n.monday;
    case 'tue':
      return l10n.tuesday;
    case 'wed':
      return l10n.wednesday;
    case 'thu':
      return l10n.thursday;
    case 'fri':
      return l10n.friday;
    case 'sat':
      return l10n.saturday;
    case 'sun':
      return l10n.sunday;
    default:
      return day;
  }
}
