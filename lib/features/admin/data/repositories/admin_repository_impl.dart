import '../../../appointments/domain/models/appointment_model.dart';
import '../../../authentication/domain/models/user_model.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._datasource);
  final AdminRemoteDatasource _datasource;

  @override
  Future<Map<String, int>> getDashboardStats() =>
      _datasource.getDashboardStats();

  @override
  Future<List<AppointmentModel>> getRecentAppointments(int limit) =>
      _datasource.getRecentAppointments(limit);

  @override
  Future<List<UserModel>> getAllPatients({int limit = 20, UserModel? lastUser}) =>
      _datasource.getAllPatients(limit: limit);

  @override
  Future<void> toggleUserStatus(String uid, bool isActive) =>
      _datasource.toggleUserStatus(uid, isActive);

  @override
  Future<void> updateAppointmentStatus(String appointmentId, String status) =>
      _datasource.updateAppointmentStatus(appointmentId, status);

  @override
  Future<List<AppointmentModel>> getAllAppointments({
    String? status,
    String? dentistId,
    DateTime? date,
  }) =>
      _datasource.getAllAppointments(status: status, dentistId: dentistId, date: date);

  @override
  Future<Map<String, Map<String, int>>> getMonthlyStats() =>
      _datasource.getMonthlyStats();

  @override
  Future<List<Map<String, dynamic>>> getTopDentists(int limit) =>
      _datasource.getTopDentists(limit);
}
