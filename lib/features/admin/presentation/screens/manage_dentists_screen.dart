import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../dentists/presentation/controllers/dentist_controller.dart';
import '../../../../core/errors/error_messages.dart';

class ManageDentistsScreen extends ConsumerStatefulWidget {
  const ManageDentistsScreen({super.key});

  @override
  ConsumerState<ManageDentistsScreen> createState() =>
      _ManageDentistsScreenState();
}

class _ManageDentistsScreenState extends ConsumerState<ManageDentistsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dentistsAsync = ref.watch(dentistListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageDentists),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/dentists/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.searchDentists,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (q) =>
                  ref.read(dentistListProvider.notifier).search(q),
            ),
          ),
          Expanded(
            child: dentistsAsync.when(
              data: (dentists) {
                if (dentists.isEmpty) {
                  return EmptyStateWidget(
                    message: l10n.noDentists,
                    icon: Icons.people_outline,
                    action: () => context.push('/admin/dentists/add'),
                    actionLabel: l10n.addDentist,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(dentistListProvider.notifier).refresh(),
                  child: ListView.builder(
                    itemCount: dentists.length,
                    itemBuilder: (context, index) {
                      final dentist = dentists[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: dentist.image.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: dentist.image,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    width: 48,
                                    height: 48,
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    child: const Icon(Icons.person,
                                        color: AppColors.primary),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 48,
                                    height: 48,
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    child: const Icon(Icons.person,
                                        color: AppColors.primary),
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  child: const Icon(Icons.person,
                                      color: AppColors.primary),
                                ),
                        ),
                        title: Text(dentist.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(dentist.specialization),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppColors.primary),
                              onPressed: () => context
                                  .push('/admin/dentists/${dentist.id}/edit'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.error),
                              onPressed: () =>
                                  _deleteDentist(context, ref, dentist.id, l10n),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const ShimmerListView(itemCount: 6),
              error: (e, _) => AppErrorWidget(
                message: context.errorMessage(e),
                onRetry: () =>
                    ref.read(dentistListProvider.notifier).refresh(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/dentists/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteDentist(BuildContext context, WidgetRef ref,
      String dentistId, AppLocalizations l10n) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.deleteDentist,
      message: l10n.deleteDentistConfirm,
      confirmLabel: l10n.delete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref
          .read(dentistRepositoryProvider)
          .deleteDentist(dentistId);
      await ref.read(dentistListProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dentistDeleted),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.errorMessage(e)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
