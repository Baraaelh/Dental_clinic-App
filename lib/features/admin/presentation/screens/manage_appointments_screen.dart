import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_appointment_tile.dart';

class ManageAppointmentsScreen extends ConsumerStatefulWidget {
  const ManageAppointmentsScreen({super.key});

  @override
  ConsumerState<ManageAppointmentsScreen> createState() =>
      _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState
    extends ConsumerState<ManageAppointmentsScreen> {
  final _statuses = [
    '',
    AppConstants.statusPending,
    AppConstants.statusApproved,
    AppConstants.statusCompleted,
    AppConstants.statusRejected,
    AppConstants.statusCancelled,
  ];
  String _selectedStatus = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appointmentsAsync = ref.watch(adminAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageAppointments)),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = _statuses[index];
                final label = status.isEmpty ? l10n.all : status;
                final isSelected = _selectedStatus == status;
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedStatus = status);
                    ref
                        .read(adminAppointmentsProvider.notifier)
                        .filterByStatus(status);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(adminAppointmentsProvider.notifier).refresh(),
              child: appointmentsAsync.when(
                data: (appointments) {
                  if (appointments.isEmpty) {
                    return EmptyStateWidget(
                      message: l10n.noAppointments,
                      icon: Icons.calendar_today_outlined,
                    );
                  }
                  return ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final a = appointments[index];
                      return AdminAppointmentTile(
                        appointment: a,
                        onApprove: a.isPending
                            ? () => _updateStatus(
                                context, ref, a.id, AppConstants.statusApproved, a.patientId)
                            : null,
                        onReject: a.isPending
                            ? () => _updateStatus(
                                context, ref, a.id, AppConstants.statusRejected, a.patientId)
                            : null,
                        onComplete: a.isApproved
                            ? () => _updateStatus(
                                context, ref, a.id, AppConstants.statusCompleted, a.patientId)
                            : null,
                      );
                    },
                  );
                },
                loading: () => const ShimmerListView(itemCount: 6, itemHeight: 140),
                error: (e, _) => AppErrorWidget(
                  message: e.toString(),
                  onRetry: () =>
                      ref.read(adminAppointmentsProvider.notifier).refresh(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref,
      String appointmentId, String status, String patientId) async {
    try {
      await ref
          .read(adminAppointmentsProvider.notifier)
          .updateStatus(appointmentId, status, patientId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment $status'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
