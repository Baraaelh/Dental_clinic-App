import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../authentication/domain/models/user_model.dart';
import '../controllers/admin_controller.dart';
import '../../../../core/errors/error_messages.dart';

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final patientsAsync = ref.watch(allPatientsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageUsers)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(allPatientsProvider.notifier).refresh(),
        child: patientsAsync.when(
          data: (patients) {
            if (patients.isEmpty) {
              return EmptyStateWidget(
                message: l10n.noUsers,
                icon: Icons.people_outline,
              );
            }
            final controller = ref.read(allPatientsProvider.notifier);
            final showLoadMore = controller.hasMore;
            return ListView.builder(
              itemCount: patients.length + (showLoadMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == patients.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: controller.loadMore,
                        icon: const Icon(Icons.expand_more),
                        label: Text(l10n.loadMore),
                      ),
                    ),
                  );
                }
                final patient = patients[index];
                return _PatientTile(
                  patient: patient,
                  onToggle: () => ref
                      .read(allPatientsProvider.notifier)
                      .toggleStatus(patient.uid, patient.isActive),
                );
              },
            );
          },
          loading: () => const ShimmerListView(itemCount: 8),
          error: (e, _) => AppErrorWidget(
            message: context.errorMessage(e),
            onRetry: () => ref.read(allPatientsProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.patient, required this.onToggle});

  final UserModel patient;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: patient.profileImage.isNotEmpty
              ? CachedNetworkImageProvider(patient.profileImage)
              : null,
          child: patient.profileImage.isEmpty
              ? Text(
                  patient.name.isNotEmpty
                      ? patient.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          patient.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.email,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            if (patient.phone.isNotEmpty)
              Text(
                patient.phone,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: patient.isActive
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                patient.isActive ? AppLocalizations.of(context).active : AppLocalizations.of(context).inactive,
                style: TextStyle(
                  color:
                      patient.isActive ? AppColors.success : AppColors.error,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Switch(
              value: patient.isActive,
              onChanged: (_) => onToggle(),
              activeThumbColor: AppColors.success,
              inactiveThumbColor: AppColors.error,
            ),
          ],
        ),
        isThreeLine: patient.phone.isNotEmpty,
      ),
    );
  }
}
