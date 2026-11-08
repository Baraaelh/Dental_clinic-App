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
String weekdayLabel(AppLocalizations l10n, String day) {
  switch (day.toLowerCase()) {
    case 'monday':
      return l10n.monday;
    case 'tuesday':
      return l10n.tuesday;
    case 'wednesday':
      return l10n.wednesday;
    case 'thursday':
      return l10n.thursday;
    case 'friday':
      return l10n.friday;
    case 'saturday':
      return l10n.saturday;
    case 'sunday':
      return l10n.sunday;
    default:
      return day;
  }
}
