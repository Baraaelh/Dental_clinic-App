import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final actions = [
      (
        icon: Icons.calendar_today,
        label: l10n.bookAppointment,
        color: AppColors.primary,
        route: '/dentists',
      ),
      (
        icon: Icons.assignment_outlined,
        label: l10n.myAppointments,
        color: AppColors.secondary,
        route: '/appointments',
      ),
      (
        icon: Icons.medical_services_outlined,
        label: l10n.services,
        color: const Color(0xFF7B1FA2),
        route: '/services',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: actions
            .map(
              (a) => Expanded(
                child: GestureDetector(
                  onTap: () => context.go(a.route),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: a.color.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(a.icon, color: a.color, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          a.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: a.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
