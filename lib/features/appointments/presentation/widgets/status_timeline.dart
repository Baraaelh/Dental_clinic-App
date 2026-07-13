import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final steps = [
      (
        label: l10n.appointmentRequested,
        icon: Icons.check_circle,
        isActive: true,
      ),
      (
        label: l10n.appointmentReviewed,
        icon: status == AppConstants.statusRejected
            ? Icons.cancel
            : Icons.check_circle,
        isActive: status != AppConstants.statusPending,
      ),
      (
        label: l10n.appointmentFinished,
        icon: Icons.check_circle,
        isActive: status == AppConstants.statusCompleted,
      ),
    ];

    Color getStepColor(int index) {
      final step = steps[index];
      if (!step.isActive) return AppColors.textHint;
      if (status == AppConstants.statusRejected && index == 1) {
        return AppColors.statusRejected;
      }
      if (status == AppConstants.statusCancelled) return AppColors.statusCancelled;
      return AppColors.statusApproved;
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final color = getStepColor(index);
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: step.isActive
                        ? color.withValues(alpha: 0.15)
                        : AppColors.divider,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.isActive ? color : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    step.icon,
                    size: 16,
                    color: step.isActive ? color : AppColors.textHint,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: steps[index + 1].isActive ? color : AppColors.divider,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 40),
                child: Text(
                  step.label,
                  style: TextStyle(
                    color: step.isActive ? color : AppColors.textHint,
                    fontWeight:
                        step.isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
