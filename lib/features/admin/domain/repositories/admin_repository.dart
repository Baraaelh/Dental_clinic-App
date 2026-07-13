import '../../../appointments/domain/models/appointment_model.dart';
import '../../../authentication/domain/models/user_model.dart';

abstract class AdminRepository {
  Future<Map<String, int>> getDashboardStats();
  Future<List<AppointmentModel>> getRecentAppointments(int limit);
  Future<List<UserModel>> getAllPatients({int limit = 20, UserModel? lastUser});
  Future<void> toggleUserStatus(String uid, bool isActive);
  Future<void> updateAppointmentStatus(String appointmentId, String status);
  Future<List<AppointmentModel>> getAllAppointments({
    String? status,
    String? dentistId,
    DateTime? date,
  });
  Future<Map<String, Map<String, int>>> getMonthlyStats();
  Future<List<Map<String, dynamic>>> getTopDentists(int limit);
}
