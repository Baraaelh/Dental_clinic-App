import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../appointments/domain/models/appointment_model.dart';
import '../../../../l10n/app_localizations.dart';

class AdminAppointmentTile extends StatelessWidget {
  const AdminAppointmentTile({
    super.key,
    required this.appointment,
    this.onApprove,
    this.onReject,
    this.onComplete,
  });

  final AppointmentModel appointment;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context).doctorName(appointment.dentistName),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (appointment.isPaid)
                  Container(
                    margin: const EdgeInsetsDirectional.only(end: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppLocalizations.of(context).paid,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                StatusChip(status: appointment.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(appointment.date),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time_outlined,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  appointment.time,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            if (appointment.isPending || appointment.isApproved) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (appointment.isPending) ...[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusApproved,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 36),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onApprove,
                        child: Text(AppLocalizations.of(context).approveAppointment,
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusRejected,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 36),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onReject,
                        child: Text(AppLocalizations.of(context).rejectAppointment,
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                  if (appointment.isApproved) ...[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusCompleted,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 36),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onComplete,
                        child: Text(AppLocalizations.of(context).markCompleted,
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
