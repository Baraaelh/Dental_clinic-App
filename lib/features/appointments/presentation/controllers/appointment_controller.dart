import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/datasources/appointment_remote_datasource.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../domain/models/appointment_model.dart';
import '../../domain/repositories/appointment_repository.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl(AppointmentRemoteDatasource());
});

final patientAppointmentsProvider = AsyncNotifierProviderFamily<
    PatientAppointmentsController,
    List<AppointmentModel>,
    String>(PatientAppointmentsController.new);

class PatientAppointmentsController
    extends FamilyAsyncNotifier<List<AppointmentModel>, String> {
  @override
  Future<List<AppointmentModel>> build(String arg) {
    return ref.read(appointmentRepositoryProvider).getPatientAppointments(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(appointmentRepositoryProvider).getPatientAppointments(arg));
  }
}

final appointmentDetailProvider =
    AsyncNotifierProviderFamily<AppointmentDetailController, AppointmentModel, String>(
        AppointmentDetailController.new);

class AppointmentDetailController
    extends FamilyAsyncNotifier<AppointmentModel, String> {
  @override
  Future<AppointmentModel> build(String arg) {
    return ref.read(appointmentRepositoryProvider).getAppointmentById(arg);
  }

  Future<void> cancel() async {
    await ref
        .read(appointmentRepositoryProvider)
        .updateAppointmentStatus(arg, AppConstants.statusCancelled);
    ref.invalidate(bookedSlotsProvider);
    state = await AsyncValue.guard(() =>
        ref.read(appointmentRepositoryProvider).getAppointmentById(arg));
  }
}

final bookedSlotsProvider = FutureProviderFamily<List<String>,
    ({String dentistId, DateTime date})>((ref, params) {
  return ref.read(appointmentRepositoryProvider).getBookedSlots(
        dentistId: params.dentistId,
        date: params.date,
      );
});

final upcomingAppointmentProvider =
    FutureProviderFamily<AppointmentModel?, String>((ref, patientId) {
  return ref.read(appointmentRepositoryProvider).getUpcomingAppointment(patientId);
});

final bookAppointmentProvider =
    AsyncNotifierProvider<BookAppointmentController, void>(
        BookAppointmentController.new);

class BookAppointmentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> book({
    required String patientId,
    required String patientName,
    required String dentistId,
    required String dentistName,
    required DateTime date,
    required String time,
    bool isPaid = false,
  }) async {
    state = const AsyncLoading();
    try {
      final appointment = AppointmentModel(
        id: '',
        patientId: patientId,
        patientName: patientName,
        dentistId: dentistId,
        dentistName: dentistName,
        date: date,
        time: time,
        status: AppConstants.statusPending,
        createdAt: DateTime.now(),
        isPaid: isPaid,
      );

      // Reserves the slot atomically; fails if it was taken meanwhile.
      await ref.read(appointmentRepositoryProvider).createAppointment(appointment);
      ref.invalidate(bookedSlotsProvider);
      ref.invalidate(patientAppointmentsProvider(patientId));
      state = const AsyncData(null);
    } on AppException catch (e, st) {
      if (e is SlotUnavailableException) ref.invalidate(bookedSlotsProvider);
      state = AsyncError(e, st);
      // Screens show `toString()` minus the "Exception:" prefix.
      throw Exception(e.message);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
