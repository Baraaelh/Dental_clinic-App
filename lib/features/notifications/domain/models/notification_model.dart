import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.receiverId,
    required this.isRead,
    this.type,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String receiverId;
  final bool isRead;

  /// Appointment status this notification is about (e.g. "Approved"), so
  /// the app can show it in the reader's language. Null for older or custom
  /// notifications, which fall back to [title] and [body].
  final String? type;
  final DateTime? createdAt;

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      type: data['type'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'receiverId': receiverId,
      'isRead': isRead,
      if (type != null) 'type': type,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? receiverId,
    bool? isRead,
    String? type,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      receiverId: receiverId ?? this.receiverId,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
