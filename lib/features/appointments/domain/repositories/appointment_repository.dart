import '../models/appointment_model.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentModel>> getPatientAppointments(String patientId);

  Future<List<AppointmentModel>> getAllAppointments({
    String? status,
    String? dentistId,
    DateTime? date,
    int limit = 50,
  });

  Future<AppointmentModel> getAppointmentById(String id);

  Future<String> createAppointment(AppointmentModel appointment);

  Future<void> updateAppointmentStatus(String id, String status);

  Future<bool> isSlotAvailable({
    required String dentistId,
    required DateTime date,
    required String time,
  });

  Future<List<String>> getBookedSlots({
    required String dentistId,
    required DateTime date,
  });

  Future<AppointmentModel?> getUpcomingAppointment(String patientId);

  Future<List<AppointmentModel>> getRecentAppointments(int limit);

  Future<Map<String, int>> getAppointmentStats();

  Future<List<AppointmentModel>> getAppointmentsForDentist(
    String dentistId,
    String patientId,
  );
}
