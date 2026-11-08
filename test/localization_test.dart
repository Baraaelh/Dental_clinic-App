import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graduation/core/errors/app_exception.dart';
import 'package:graduation/core/errors/error_messages.dart';
import 'package:graduation/core/utils/status_labels.dart';
import 'package:graduation/features/notifications/domain/models/notification_model.dart';
import 'package:graduation/features/notifications/presentation/notification_text.dart';
import 'package:graduation/l10n/app_localizations.dart';

void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));
  final en = lookupAppLocalizations(const Locale('en'));

  group('localizedErrorMessage', () {
    test('maps app error codes to translated text', () {
      expect(localizedErrorMessage(ar, const SlotUnavailableException()),
          ar.slotAlreadyBooked);
      expect(
          localizedErrorMessage(
              ar,
              const ValidationException('x',
                  code: AppErrorCodes.alreadyReviewed)),
          ar.alreadyReviewed);
      expect(
          localizedErrorMessage(
              en, const AuthException('x', code: 'invalid-credential')),
          en.errorInvalidCredential);
    });

    test('never shows raw technical messages', () {
      const raw = ServerException(
          'Failed to load: [cloud_firestore/internal] stack trace...');
      expect(localizedErrorMessage(ar, raw), ar.somethingWentWrong);
      expect(
          localizedErrorMessage(ar,
              const ServerException('[cloud_firestore/permission-denied] no')),
          ar.errorPermissionDenied);
    });
  });

  test('status and weekday labels are translated', () {
    expect(appointmentStatusLabel(ar, 'Pending'), 'قيد الانتظار');
    expect(appointmentStatusLabel(en, 'Approved'), 'Approved');
    expect(weekdayLabel(ar, 'Sunday'), ar.sunday);
  });

  test('status notifications follow the reader language; others keep text',
      () {
    const typed = NotificationModel(
        id: '1',
        title: 'Appointment Approved',
        body: 'Your appointment has been approved.',
        receiverId: 'u',
        isRead: false,
        type: 'Approved');
    expect(localizedNotificationText(ar, typed).title,
        ar.notificationTitleApproved);

    const custom = NotificationModel(
        id: '2', title: 'Hello', body: 'Custom', receiverId: 'u', isRead: false);
    expect(localizedNotificationText(ar, custom).title, 'Hello');
  });

  test('Arabic and English translation files have the same keys', () {
    // gen-l10n would also report this, but keep it explicit.
    expect(ar.paid, isNot(en.paid));
    expect(ar.payByCardSubtitle, isNotEmpty);
  });
}
