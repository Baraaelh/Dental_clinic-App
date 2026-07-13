import '../../domain/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._datasource);
  final NotificationRemoteDatasource _datasource;

  @override
  Future<List<NotificationModel>> getNotifications(String userId) =>
      _datasource.getNotifications(userId);

  @override
  Future<void> markAsRead(String notificationId) =>
      _datasource.markAsRead(notificationId);

  @override
  Future<void> markAllAsRead(String userId) =>
      _datasource.markAllAsRead(userId);

  @override
  Future<int> getUnreadCount(String userId) =>
      _datasource.getUnreadCount(userId);

  @override
  Future<String> createNotification(NotificationModel notification) =>
      _datasource.createNotification(notification);
}
