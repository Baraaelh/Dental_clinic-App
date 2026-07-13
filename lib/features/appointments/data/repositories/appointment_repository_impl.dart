import '../../domain/models/appointment_model.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl(this._datasource);
  final AppointmentRemoteDatasource _datasource;

  @override
  Future<List<AppointmentModel>> getPatientAppointments(String patientId) =>
      _datasource.getPatientAppointments(patientId);

  @override
  Future<List<AppointmentModel>> getAllAppointments({
    String? status,
    String? dentistId,
    DateTime? date,
    int limit = 50,
  }) =>
      _datasource.getAllAppointments(
          status: status, dentistId: dentistId, date: date, limit: limit);

  @override
  Future<AppointmentModel> getAppointmentById(String id) =>
      _datasource.getAppointmentById(id);

  @override
  Future<String> createAppointment(AppointmentModel appointment) =>
      _datasource.createAppointment(appointment);

  @override
  Future<void> updateAppointmentStatus(String id, String status) =>
      _datasource.updateAppointmentStatus(id, status);

  @override
  Future<bool> isSlotAvailable({
    required String dentistId,
    required DateTime date,
    required String time,
  }) =>
      _datasource.isSlotAvailable(dentistId: dentistId, date: date, time: time);

  @override
  Future<List<String>> getBookedSlots({
    required String dentistId,
    required DateTime date,
  }) =>
      _datasource.getBookedSlots(dentistId: dentistId, date: date);

  @override
  Future<AppointmentModel?> getUpcomingAppointment(String patientId) =>
      _datasource.getUpcomingAppointment(patientId);

  @override
  Future<List<AppointmentModel>> getRecentAppointments(int limit) =>
      _datasource.getRecentAppointments(limit);

  @override
  Future<Map<String, int>> getAppointmentStats() =>
      _datasource.getAppointmentStats();

  @override
  Future<List<AppointmentModel>> getAppointmentsForDentist(
    String dentistId,
    String patientId,
  ) =>
      _datasource.getAppointmentsForDentist(dentistId, patientId);
}
