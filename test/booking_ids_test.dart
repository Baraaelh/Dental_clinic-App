import 'package:flutter_test/flutter_test.dart';
import 'package:graduation/features/appointments/data/datasources/appointment_remote_datasource.dart';
import 'package:graduation/features/reviews/data/datasources/review_remote_datasource.dart';

void main() {
  group('AppointmentRemoteDatasource.slotIdFor', () {
    test('matches the id format the Firestore rules expect', () {
      expect(
        AppointmentRemoteDatasource.slotIdFor(
            'dentist1', DateTime(2026, 3, 7), '09:30'),
        'dentist1_2026-03-07_09:30',
      );
    });

    test('uses the calendar day of UTC dates from the calendar widget', () {
      expect(
        AppointmentRemoteDatasource.slotIdFor(
            'd', DateTime.utc(2026, 12, 31), '16:00'),
        'd_2026-12-31_16:00',
      );
    });

    test('ignores the time-of-day part of the date', () {
      expect(
        AppointmentRemoteDatasource.slotIdFor(
            'd', DateTime(2026, 1, 2, 23, 59), '10:00'),
        AppointmentRemoteDatasource.slotIdFor(
            'd', DateTime(2026, 1, 2), '10:00'),
      );
    });
  });

  test('ReviewRemoteDatasource.reviewIdFor is one review per patient/dentist',
      () {
    expect(ReviewRemoteDatasource.reviewIdFor('p1', 'd1'), 'p1_d1');
  });
}
