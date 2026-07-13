import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/notification_model.dart';

class NotificationRemoteDatasource {
  NotificationRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.notificationsCollection);

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final snapshot = await _collection
          .where('receiverId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map(NotificationModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to load notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _collection.doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw ServerException('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _collection
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to mark all notifications as read: $e');
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _collection
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<String> createNotification(NotificationModel notification) async {
    try {
      final ref = await _collection.add(notification.toMap());
      return ref.id;
    } catch (e) {
      throw ServerException('Failed to create notification: $e');
    }
  }
}
