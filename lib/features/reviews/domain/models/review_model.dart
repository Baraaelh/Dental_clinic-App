import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientImage,
    required this.dentistId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final String patientName;
  final String patientImage;
  final String dentistId;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      patientId: data['patientId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      patientImage: data['patientImage'] as String? ?? '',
      dentistId: data['dentistId'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'patientImage': patientImage,
      'dentistId': dentistId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
