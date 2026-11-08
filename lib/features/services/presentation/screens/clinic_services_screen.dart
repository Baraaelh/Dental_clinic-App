import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../controllers/services_controller.dart';
import '../widgets/service_card.dart';
import '../../../../core/errors/error_messages.dart';

class ClinicServicesScreen extends ConsumerWidget {
  const ClinicServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l10n.clinicServicesTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(servicesProvider.notifier).refresh(),
        child: servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return EmptyStateWidget(
                message: l10n.noServices,
                icon: Icons.medical_services_outlined,
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) =>
                  ServiceCard(service: services[index]),
            );
          },
          loading: () => _ShimmerGrid(),
          error: (e, _) => AppErrorWidget(
            message: context.errorMessage(e),
            onRetry: () => ref.read(servicesProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
