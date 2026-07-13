import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../appointments/presentation/controllers/appointment_controller.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../services/presentation/controllers/services_controller.dart';
import '../../../services/presentation/widgets/service_card.dart';
import '../widgets/featured_dentists_section.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/upcoming_appointment_card.dart';
import '../widgets/welcome_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authAsync = ref.watch(authStateProvider);
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/notifications'),
          ),
        ],
      ),
      body: authAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: CircularProgressIndicator()),
        data: (user) {
          if (user == null) return const Center(child: CircularProgressIndicator());
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(servicesProvider);
              ref.invalidate(upcomingAppointmentProvider(user.uid));
            },
            child: ListView(
              children: [
                WelcomeCard(user: user),
                const SizedBox(height: 20),
                const QuickActionsRow(),
                const SizedBox(height: 24),
                const UpcomingAppointmentCard(),
                const SizedBox(height: 24),
                const FeaturedDentistsSection(),
                const SizedBox(height: 24),
                _ServicesSection(
                  servicesAsync: servicesAsync,
                  onViewAll: () => context.go('/services'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({
    required this.servicesAsync,
    required this.onViewAll,
  });

  final AsyncValue servicesAsync;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.clinicServices,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(l10n.viewAll),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        servicesAsync.when(
          data: (services) {
            final list = (services as List).take(4).toList();
            if (list.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: list.length,
                itemBuilder: (context, index) => SizedBox(
                  width: 140,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ServiceCard(service: list[index]),
                  ),
                ),
              ),
            );
          },
          loading: () => const SizedBox(height: 180),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
