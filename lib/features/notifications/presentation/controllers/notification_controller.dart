import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(NotificationRemoteDatasource());
});

final notificationsProvider = AsyncNotifierProviderFamily<
    NotificationsController,
    List<NotificationModel>,
    String>(NotificationsController.new);

class NotificationsController
    extends FamilyAsyncNotifier<List<NotificationModel>, String> {
  @override
  Future<List<NotificationModel>> build(String arg) {
    return ref.read(notificationRepositoryProvider).getNotifications(arg);
  }

  Future<void> markAsRead(String notificationId) async {
    await ref
        .read(notificationRepositoryProvider)
        .markAsRead(notificationId);

    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((n) {
        if (n.id == notificationId) return n.copyWith(isRead: true);
        return n;
      }).toList(),
    );
  }

  Future<void> markAllAsRead() async {
    await ref.read(notificationRepositoryProvider).markAllAsRead(arg);
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(notificationRepositoryProvider).getNotifications(arg));
  }

  int get unreadCount {
    final notifications = state.valueOrNull ?? [];
    return notifications.where((n) => !n.isRead).length;
  }
}

final unreadCountProvider = Provider.family<int, String>((ref, userId) {
  final notificationsAsync = ref.watch(notificationsProvider(userId));
  return notificationsAsync.valueOrNull?.where((n) => !n.isRead).length ?? 0;
});
