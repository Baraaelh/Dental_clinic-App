import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../controllers/appointment_controller.dart';
import '../widgets/status_timeline.dart';

class AppointmentDetailsScreen extends ConsumerWidget {
  const AppointmentDetailsScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appointmentAsync =
        ref.watch(appointmentDetailProvider(appointmentId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l10n.appointmentDetails),
      ),
      body: appointmentAsync.when(
        data: (appointment) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.medical_services,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment.dentistName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  StatusChip(status: appointment.status),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: l10n.appointmentDate,
                          value: DateFormat('EEEE, MMM dd, yyyy')
                              .format(appointment.date),
                          icon: Icons.calendar_today,
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: l10n.appointmentTime,
                          value: appointment.time,
                          icon: Icons.access_time,
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: l10n.appointmentStatus,
                          value: appointment.status,
                          icon: Icons.info_outline,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.statusTimeline,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                StatusTimeline(status: appointment.status),
                if (appointment.canCancel) ...[
                  const SizedBox(height: 16),
                  AppButton(
                    label: l10n.cancelAppointment,
                    onPressed: () => _cancel(context, ref, l10n),
                    variant: AppButtonVariant.outlined,
                    icon: Icons.cancel_outlined,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(appointmentDetailProvider(appointmentId)),
        ),
      ),
    );
  }

  Future<void> _cancel(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.cancelAppointmentConfirmTitle,
      message: l10n.cancelAppointmentConfirmMessage,
      confirmLabel: l10n.cancelAppointment,
      cancelLabel: l10n.back,
      isDestructive: true,
      icon: Icons.cancel_outlined,
    );

    if (!confirmed || !context.mounted) return;

    try {
      await ref
          .read(appointmentDetailProvider(appointmentId).notifier)
          .cancel();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appointmentCancelled),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
