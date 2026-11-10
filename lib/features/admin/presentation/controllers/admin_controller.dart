import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../appointments/domain/models/appointment_model.dart';
import '../../../authentication/domain/models/user_model.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(AdminRemoteDatasource());
});

final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.read(adminRepositoryProvider).getDashboardStats();
});

final recentAdminAppointmentsProvider =
    FutureProvider<List<AppointmentModel>>((ref) {
  return ref
      .read(adminRepositoryProvider)
      .getRecentAppointments(AppConstants.recentAppointmentsCount);
});

final allPatientsProvider =
    AsyncNotifierProvider<PatientsController, List<UserModel>>(
        PatientsController.new);

class PatientsController extends AsyncNotifier<List<UserModel>> {
  static const pageSize = 20;

  bool _hasMore = true;
  bool _loadingMore = false;

  /// Whether another page of patients may exist.
  bool get hasMore => _hasMore;

  Future<List<UserModel>> _page({UserModel? after}) async {
    final page = await ref
        .read(adminRepositoryProvider)
        .getAllPatients(limit: pageSize, lastUser: after);
    _hasMore = page.length == pageSize;
    return page;
  }

  @override
  Future<List<UserModel>> build() => _page();

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isEmpty || !_hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final more = await _page(after: current.last);
      state = AsyncData([...current, ...more]);
    } catch (e, st) {
      state = AsyncError<List<UserModel>>(e, st).copyWithPrevious(state);
    } finally {
      _loadingMore = false;
    }
  }

  /// Blocks/unblocks a patient and updates the list in place (keeps the
  /// pages already loaded).
  Future<void> toggleStatus(String uid, bool currentStatus) async {
    await ref
        .read(adminRepositoryProvider)
        .toggleUserStatus(uid, !currentStatus);
    final current = state.valueOrNull ?? const <UserModel>[];
    state = AsyncData([
      for (final u in current)
        u.uid == uid ? u.copyWith(isActive: !currentStatus) : u,
    ]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_page);
  }
}

final adminAppointmentsProvider =
    AsyncNotifierProvider<AdminAppointmentsController, List<AppointmentModel>>(
        AdminAppointmentsController.new);

class AdminAppointmentsController
    extends AsyncNotifier<List<AppointmentModel>> {
  String _statusFilter = '';
  String _dentistFilter = '';

  @override
  Future<List<AppointmentModel>> build() => _fetch();

  Future<List<AppointmentModel>> _fetch() {
    return ref.read(adminRepositoryProvider).getAllAppointments(
          status: _statusFilter.isEmpty ? null : _statusFilter,
          dentistId: _dentistFilter.isEmpty ? null : _dentistFilter,
        );
  }

  Future<void> filterByStatus(String status) async {
    _statusFilter = status;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> filterByDentist(String dentistId) async {
    _dentistFilter = dentistId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> updateStatus(
      String appointmentId, String status, String patientId) async {
    final datasource = AdminRemoteDatasource();
    await datasource.updateAppointmentStatus(appointmentId, status);

    final title = _getNotificationTitle(status);
    if (title != null) {
      await datasource.sendNotification(
        receiverId: patientId,
        title: title,
        body: _getNotificationBody(status),
        type: status,
      );
    }

    await refresh();
  }

  // English fallback text, stored for older app versions and the web
  // dashboard. The app itself shows the translated text based on `type`.
  String? _getNotificationTitle(String status) {
    switch (status) {
      case AppConstants.statusApproved:
        return 'Appointment Approved';
      case AppConstants.statusRejected:
        return 'Appointment Rejected';
      case AppConstants.statusCancelled:
        return 'Appointment Cancelled';
      case AppConstants.statusCompleted:
        return 'Appointment Completed';
      default:
        return null;
    }
  }

  String _getNotificationBody(String status) {
    switch (status) {
      case AppConstants.statusApproved:
        return 'Your appointment has been approved. We will see you soon!';
      case AppConstants.statusRejected:
        return 'Unfortunately, your appointment request has been rejected.';
      case AppConstants.statusCancelled:
        return 'Your appointment has been cancelled.';
      case AppConstants.statusCompleted:
        return 'Your appointment has been marked as completed. Thank you for visiting us!';
      default:
        return '';
    }
  }
}

final monthlyStatsProvider =
    FutureProvider<Map<String, Map<String, int>>>((ref) {
  return ref.read(adminRepositoryProvider).getMonthlyStats();
});
