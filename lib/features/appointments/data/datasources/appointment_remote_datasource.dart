import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/appointment_model.dart';

class AppointmentRemoteDatasource {
  AppointmentRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.appointmentsCollection);

  Future<List<AppointmentModel>> getPatientAppointments(
      String patientId) async {
    try {
      // Single-field equality query (no composite index required).
      // Sorting is done in Dart to avoid the (patientId, date) composite index.
      final snapshot = await _collection
          .where('patientId', isEqualTo: patientId)
          .get();
      final appointments = snapshot.docs
          .map(AppointmentModel.fromFirestore)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      return appointments;
    } catch (e) {
      debugPrint('getPatientAppointments error: $e');
      throw ServerException('Failed to load appointments: $e');
    }
  }

  Future<List<AppointmentModel>> getAllAppointments({
    String? status,
    String? dentistId,
    DateTime? date,
    int limit = 50,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection;

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }
      if (dentistId != null && dentistId.isNotEmpty) {
        query = query.where('dentistId', isEqualTo: dentistId);
      }
      if (date != null) {
        final start = DateTime(date.year, date.month, date.day);
        final end = start.add(const Duration(days: 1));
        query = query
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('date', isLessThan: Timestamp.fromDate(end));
      }

      final snapshot = await query
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map(AppointmentModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to load appointments: $e');
    }
  }

  Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      final doc = await _collection
          .doc(id)
          .get();
      if (!doc.exists) throw const NotFoundException('Appointment not found');
      return AppointmentModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Failed to load appointment: $e');
    }
  }

  CollectionReference<Map<String, dynamic>> get _slots =>
      _firestore.collection(AppConstants.bookedSlotsCollection);

  /// Deterministic id of the `booked_slots` document for a dentist/day/time.
  /// Only one document can exist per id, which is what blocks double booking.
  static String slotIdFor(String dentistId, DateTime date, String time) =>
      '${dentistId}_${slotDateKey(date)}_$time';

  /// Calendar day as `yyyy-MM-dd`, using the date's own fields so the result
  /// is the same for UTC dates (from the calendar widget) and local dates.
  static String slotDateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Books the appointment and reserves its time slot in one transaction.
  /// Throws [SlotUnavailableException] if someone else already holds the slot.
  Future<String> createAppointment(AppointmentModel appointment) async {
    final day = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
    );
    final slotId = slotIdFor(appointment.dentistId, day, appointment.time);
    final slotRef = _slots.doc(slotId);
    final apptRef = _collection.doc();

    try {
      await _firestore.runTransaction((tx) async {
        final slot = await tx.get(slotRef);
        if (slot.exists) throw const SlotUnavailableException();

        tx.set(
          apptRef,
          appointment.copyWith(date: day, slotId: slotId).toMap(),
        );
        tx.set(slotRef, {
          'dentistId': appointment.dentistId,
          'date': slotDateKey(day),
          'time': appointment.time,
          'appointmentId': apptRef.id,
        });
      });
      return apptRef.id;
    } on SlotUnavailableException {
      rethrow;
    } on FirebaseException catch (e) {
      // If another patient grabbed the slot between our read and the commit,
      // the rules reject the slot write (it is no longer a create).
      if (e.code == 'permission-denied' || e.code == 'aborted') {
        final taken = await _slots.doc(slotId).get().then((d) => d.exists,
            onError: (_) => false);
        if (taken) throw const SlotUnavailableException();
      }
      throw ServerException('Failed to create appointment: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create appointment: $e');
    }
  }

  /// Changes an appointment's status. Cancelling or rejecting frees the
  /// reserved slot so another patient can book it.
  Future<void> updateAppointmentStatus(String id, String status) async {
    final releasesSlot = status == AppConstants.statusCancelled ||
        status == AppConstants.statusRejected;
    try {
      if (!releasesSlot) {
        await _collection.doc(id).update({'status': status});
        return;
      }
      await _firestore.runTransaction((tx) async {
        final apptRef = _collection.doc(id);
        final appt = await tx.get(apptRef);
        if (!appt.exists) throw const NotFoundException('Appointment not found');
        tx.update(apptRef, {'status': status});
        final slotId = appt.data()?['slotId'] as String?;
        if (slotId != null) tx.delete(_slots.doc(slotId));
      });
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update appointment: $e');
    }
  }

  Future<bool> isSlotAvailable({
    required String dentistId,
    required DateTime date,
    required String time,
  }) async {
    try {
      final slot = await _slots.doc(slotIdFor(dentistId, date, time)).get();
      return !slot.exists;
    } catch (e) {
      debugPrint('isSlotAvailable error: $e');
      throw ServerException('Failed to check slot availability: $e');
    }
  }

  /// Times already taken for a dentist on a given day. Reads the public
  /// `booked_slots` collection, because patients may not read other
  /// patients' appointments.
  Future<List<String>> getBookedSlots({
    required String dentistId,
    required DateTime date,
  }) async {
    try {
      final snapshot = await _slots
          .where('dentistId', isEqualTo: dentistId)
          .where('date', isEqualTo: slotDateKey(date))
          .get();
      return snapshot.docs
          .map((d) => d.data()['time'] as String? ?? '')
          .where((t) => t.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('getBookedSlots error: $e');
      throw ServerException('Failed to get booked slots: $e');
    }
  }

  Future<AppointmentModel?> getUpcomingAppointment(String patientId) async {
    try {
      // Single-field equality query avoids the composite index that the
      // multi-field version (whereIn + range + orderBy) would require.
      // Status and date filtering are handled in Dart.
      final snapshot = await _collection
          .where('patientId', isEqualTo: patientId)
          .get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final upcoming = snapshot.docs
          .map(AppointmentModel.fromFirestore)
          .where((a) =>
              !a.date.isBefore(today) &&
              (a.status == AppConstants.statusPending ||
                  a.status == AppConstants.statusApproved))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      return upcoming.isEmpty ? null : upcoming.first;
    } catch (e) {
      debugPrint('getUpcomingAppointment error: $e');
      return null;
    }
  }

  Future<List<AppointmentModel>> getRecentAppointments(int limit) async {
    try {
      final snapshot = await _collection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map(AppointmentModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to load recent appointments: $e');
    }
  }

  Future<Map<String, int>> getAppointmentStats() async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final allSnap = await _collection.get();
      final todaySnap = await _collection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('date', isLessThan: Timestamp.fromDate(todayEnd))
          .get();
      final pendingSnap = await _collection
          .where('status', isEqualTo: AppConstants.statusPending)
          .get();

      return {
        'total': allSnap.size,
        'today': todaySnap.size,
        'pending': pendingSnap.size,
      };
    } catch (e) {
      throw ServerException('Failed to get appointment stats: $e');
    }
  }

  Future<List<AppointmentModel>> getAppointmentsForDentist(
    String dentistId,
    String patientId,
  ) async {
    try {
      final snapshot = await _collection
          .where('dentistId', isEqualTo: dentistId)
          .where('patientId', isEqualTo: patientId)
          .where('status', isEqualTo: AppConstants.statusCompleted)
          .get();
      return snapshot.docs.map(AppointmentModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to load appointments: $e');
    }
  }
}
