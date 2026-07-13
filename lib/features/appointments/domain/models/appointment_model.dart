import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.dentistId,
    required this.dentistName,
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
    this.createdAt,
    this.isPaid = false,
  });

  final String id;
  final String patientId;
  final String dentistId;
  final String dentistName;
  final String patientName;
  final DateTime date;
  final String time;
  final String status;
  final DateTime? createdAt;
  final bool isPaid;

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      patientId: data['patientId'] as String? ?? '',
      dentistId: data['dentistId'] as String? ?? '',
      dentistName: data['dentistName'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] as String? ?? '',
      status: data['status'] as String? ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isPaid: data['isPaid'] as bool? ?? false,
    );
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> data, String id) {
    return AppointmentModel(
      id: id,
      patientId: data['patientId'] as String? ?? '',
      dentistId: data['dentistId'] as String? ?? '',
      dentistName: data['dentistName'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] as String? ?? '',
      status: data['status'] as String? ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isPaid: data['isPaid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'dentistId': dentistId,
      'dentistName': dentistName,
      'patientName': patientName,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status,
      'isPaid': isPaid,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? dentistId,
    String? dentistName,
    String? patientName,
    DateTime? date,
    String? time,
    String? status,
    DateTime? createdAt,
    bool? isPaid,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      dentistId: dentistId ?? this.dentistId,
      dentistName: dentistName ?? this.dentistName,
      patientName: patientName ?? this.patientName,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isCompleted => status == 'Completed';
  bool get isRejected => status == 'Rejected';
  bool get isCancelled => status == 'Cancelled';
  bool get isUpcoming => isPending || isApproved;
  bool get isHistory => isCompleted || isRejected || isCancelled;
  bool get canCancel => isPending || isApproved;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
