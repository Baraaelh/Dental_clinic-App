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

  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      final ref = await _collection.add(appointment.toMap());
      return ref.id;
    } catch (e) {
      throw ServerException('Failed to create appointment: $e');
    }
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    try {
      await _collection.doc(id).update({'status': status});
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
      final booked = await getBookedSlots(dentistId: dentistId, date: date);
      return !booked.contains(time);
    } catch (e) {
      debugPrint('isSlotAvailable error: $e');
      throw ServerException('Failed to check slot availability: $e');
    }
  }

  Future<List<String>> getBookedSlots({
    required String dentistId,
    required DateTime date,
  }) async {
    try {
      // Single-field equality query to avoid composite index requirement.
      // Date and status filtering is done in Dart.
      final snapshot = await _collection
          .where('dentistId', isEqualTo: dentistId)
          .get();

      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      return snapshot.docs
          .map(AppointmentModel.fromFirestore)
          .where((a) =>
              !a.date.isBefore(dayStart) &&
              a.date.isBefore(dayEnd) &&
              a.status != AppConstants.statusCancelled &&
              a.status != AppConstants.statusRejected)
          .map((a) => a.time)
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
