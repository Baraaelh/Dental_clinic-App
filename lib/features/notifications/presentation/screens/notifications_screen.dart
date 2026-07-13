import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(l10n.notifications),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final notificationsAsync = ref.watch(notificationsProvider(user.uid));
    final unread = notificationsAsync.valueOrNull?.where((n) => !n.isRead).length ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l10n.notifications),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => ref
                  .read(notificationsProvider(user.uid).notifier)
                  .markAllAsRead(),
              child: Text(
                l10n.markAllRead,
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationsProvider(user.uid).notifier).refresh(),
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return EmptyStateWidget(
                message: l10n.noNotifications,
                icon: Icons.notifications_off_outlined,
              );
            }
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () {
                    if (!notification.isRead) {
                      ref
                          .read(notificationsProvider(user.uid).notifier)
                          .markAsRead(notification.id);
                    }
                  },
                );
              },
            );
          },
          loading: () => const ShimmerListView(itemCount: 8, itemHeight: 80),
          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () =>
                ref.read(notificationsProvider(user.uid).notifier).refresh(),
          ),
        ),
      ),
    );
  }
}
