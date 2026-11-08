import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/helpers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../domain/models/appointment_model.dart';
import '../controllers/appointment_controller.dart';
import '../widgets/appointment_card.dart';
import '../../../../core/errors/error_messages.dart';

class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myAppointments)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.myAppointments),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.upcoming),
              Tab(text: l10n.history),
            ],
          ),
        ),
        body: Consumer(
          builder: (context, ref, _) {
            final appointmentsAsync =
                ref.watch(patientAppointmentsProvider(user.uid));

            return appointmentsAsync.when(
              data: (appointments) {
                final upcoming = appointments
                    .where((a) => AppHelpers.isUpcomingStatus(a.status))
                    .toList();
                final history = appointments
                    .where((a) => AppHelpers.isHistoryStatus(a.status))
                    .toList();

                return TabBarView(
                  children: [
                    _AppointmentList(
                      appointments: upcoming,
                      emptyMessage: l10n.noUpcomingAppointmentsHistory,
                      onRefresh: () => ref
                          .read(patientAppointmentsProvider(user.uid).notifier)
                          .refresh(),
                    ),
                    _AppointmentList(
                      appointments: history,
                      emptyMessage: l10n.noHistoryAppointments,
                      onRefresh: () => ref
                          .read(patientAppointmentsProvider(user.uid).notifier)
                          .refresh(),
                    ),
                  ],
                );
              },
              loading: () => const TabBarView(
                children: [
                  ShimmerListView(itemCount: 4, itemHeight: 120),
                  ShimmerListView(itemCount: 4, itemHeight: 120),
                ],
              ),
              error: (e, _) => TabBarView(
                children: [
                  AppErrorWidget(
                    message: context.errorMessage(e),
                    onRetry: () => ref
                        .read(patientAppointmentsProvider(user.uid).notifier)
                        .refresh(),
                  ),
                  AppErrorWidget(message: context.errorMessage(e)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({
    required this.appointments,
    required this.emptyMessage,
    required this.onRefresh,
  });

  final List<AppointmentModel> appointments;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return EmptyStateWidget(
        message: emptyMessage,
        icon: Icons.calendar_today_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: appointments.length,
        itemBuilder: (context, index) =>
            AppointmentCard(appointment: appointments[index]),
      ),
    );
  }
}
