import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_appointment_tile.dart';
import '../widgets/stat_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final recentAsync = ref.watch(recentAdminAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        actions: [
          PopupMenuButton<String>(
            onSelected: (route) => context.push(route),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: '/admin/dentists', child: Text('Dentists')),
              const PopupMenuItem(
                  value: '/admin/appointments', child: Text('Appointments')),
              const PopupMenuItem(value: '/admin/services', child: Text('Services')),
              const PopupMenuItem(value: '/admin/users', child: Text('Users')),
              const PopupMenuItem(value: '/admin/reviews', child: Text('Reviews')),
              const PopupMenuItem(
                  value: '/admin/statistics', child: Text('Statistics')),
            ],
          ),
        ],
      ),
      drawer: _AdminDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentAdminAppointmentsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            statsAsync.when(
              data: (stats) => GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    title: l10n.totalPatients,
                    value: '${stats['patients'] ?? 0}',
                    icon: Icons.people,
                    color: AppColors.primary,
                    onTap: () => context.push('/admin/users'),
                  ),
                  StatCard(
                    title: l10n.todaysAppointments,
                    value: '${stats['today'] ?? 0}',
                    icon: Icons.calendar_today,
                    color: AppColors.secondary,
                    onTap: () => context.push('/admin/appointments'),
                  ),
                  StatCard(
                    title: l10n.pendingApprovals,
                    value: '${stats['pending'] ?? 0}',
                    icon: Icons.pending_actions,
                    color: AppColors.warning,
                    onTap: () => context.push('/admin/appointments'),
                  ),
                  StatCard(
                    title: l10n.totalDentists,
                    value: '${stats['dentists'] ?? 0}',
                    icon: Icons.medical_services,
                    color: const Color(0xFF7B1FA2),
                    onTap: () => context.push('/admin/dentists'),
                  ),
                ],
              ),
              loading: () => const SizedBox(
                height: 200,
                child: LoadingWidget(),
              ),
              error: (e, _) => AppErrorWidget(message: e.toString()),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentAppointments,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push('/admin/appointments'),
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            recentAsync.when(
              data: (appointments) => Column(
                children: appointments
                    .map((a) => AdminAppointmentTile(
                          appointment: a,
                          onApprove: () => ref
                              .read(adminAppointmentsProvider.notifier)
                              .updateStatus(a.id, 'Approved', a.patientId),
                          onReject: () => ref
                              .read(adminAppointmentsProvider.notifier)
                              .updateStatus(a.id, 'Rejected', a.patientId),
                          onComplete: () => ref
                              .read(adminAppointmentsProvider.notifier)
                              .updateStatus(a.id, 'Completed', a.patientId),
                        ))
                    .toList(),
              ),
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(message: e.toString()),
            ),
            const SizedBox(height: 16),
            Text(
              'Quick Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickActionChip(
                  label: 'Add Dentist',
                  icon: Icons.person_add,
                  onTap: () => context.push('/admin/dentists/add'),
                ),
                _QuickActionChip(
                  label: 'Statistics',
                  icon: Icons.bar_chart,
                  onTap: () => context.push('/admin/statistics'),
                ),
                _QuickActionChip(
                  label: 'Manage Services',
                  icon: Icons.medical_services,
                  onTap: () => context.push('/admin/services'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _AdminDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradient1, AppColors.gradient2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text(
                  user?.name ?? 'Admin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(l10n.manageDentists),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/dentists');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(l10n.manageAppointments),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/appointments');
            },
          ),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: Text(l10n.manageServices),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/services');
            },
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: Text(l10n.manageUsers),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: Text(l10n.manageReviews),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/reviews');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(l10n.statistics),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/statistics');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              l10n.logout,
              style: const TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
