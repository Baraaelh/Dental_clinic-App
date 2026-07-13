import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../appointments/domain/models/appointment_model.dart';
import '../../../authentication/domain/models/user_model.dart';

class AdminRemoteDatasource {
  AdminRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, int>> getDashboardStats() async {
    try {
      final usersSnap = await _firestore
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: AppConstants.rolePatient)
          .count()
          .get();

      final dentistsSnap = await _firestore
          .collection(AppConstants.dentistsCollection)
          .count()
          .get();

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final todaySnap = await _firestore
          .collection(AppConstants.appointmentsCollection)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('date', isLessThan: Timestamp.fromDate(todayEnd))
          .count()
          .get();

      final pendingSnap = await _firestore
          .collection(AppConstants.appointmentsCollection)
          .where('status', isEqualTo: AppConstants.statusPending)
          .count()
          .get();

      final totalSnap = await _firestore
          .collection(AppConstants.appointmentsCollection)
          .count()
          .get();

      final completedSnap = await _firestore
          .collection(AppConstants.appointmentsCollection)
          .where('status', isEqualTo: AppConstants.statusCompleted)
          .count()
          .get();

      return {
        'patients': usersSnap.count ?? 0,
        'dentists': dentistsSnap.count ?? 0,
        'today': todaySnap.count ?? 0,
        'pending': pendingSnap.count ?? 0,
        'total': totalSnap.count ?? 0,
        'completed': completedSnap.count ?? 0,
      };
    } catch (e) {
      throw ServerException('Failed to load dashboard stats: $e');
    }
  }

  Future<List<AppointmentModel>> getRecentAppointments(int limit) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.appointmentsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map(AppointmentModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to load appointments: $e');
    }
  }

  Future<List<UserModel>> getAllPatients({
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: AppConstants.rolePatient)
          .orderBy('name')
          .limit(limit);

      if (lastDoc != null) query = query.startAfterDocument(lastDoc);

      final snapshot = await query.get();
      return snapshot.docs
          .map((d) => UserModel.fromFirestore(
              d as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to load patients: $e');
    }
  }

  Future<void> toggleUserStatus(String uid, bool isActive) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'isActive': isActive});
    } catch (e) {
      throw ServerException('Failed to toggle user status: $e');
    }
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await _firestore
          .collection(AppConstants.appointmentsCollection)
          .doc(appointmentId)
          .update({'status': status});
    } catch (e) {
      throw ServerException('Failed to update appointment: $e');
    }
  }

  Future<List<AppointmentModel>> getAllAppointments({
    String? status,
    String? dentistId,
    DateTime? date,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection(AppConstants.appointmentsCollection);

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
          .limit(100)
          .get();
      return snapshot.docs.map(AppointmentModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to load appointments: $e');
    }
  }

  Future<Map<String, Map<String, int>>> getMonthlyStats() async {
    try {
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
      final snapshot = await _firestore
          .collection(AppConstants.appointmentsCollection)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo))
          .get();

      final stats = <String, Map<String, int>>{};
      for (final doc in snapshot.docs) {
        final appointment = AppointmentModel.fromFirestore(doc);
        final key =
            '${appointment.date.year}-${appointment.date.month.toString().padLeft(2, '0')}';
        stats[key] ??= {
          AppConstants.statusPending: 0,
          AppConstants.statusApproved: 0,
          AppConstants.statusCompleted: 0,
          AppConstants.statusRejected: 0,
          AppConstants.statusCancelled: 0,
        };
        stats[key]![appointment.status] =
            (stats[key]![appointment.status] ?? 0) + 1;
      }
      return stats;
    } catch (e) {
      throw ServerException('Failed to load monthly stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopDentists(int limit) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.dentistsCollection)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      throw ServerException('Failed to load top dentists: $e');
    }
  }

  Future<void> sendNotification({
    required String receiverId,
    required String title,
    required String body,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .add({
            'receiverId': receiverId,
            'title': title,
            'body': body,
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw ServerException('Failed to send notification: $e');
    }
  }
}
