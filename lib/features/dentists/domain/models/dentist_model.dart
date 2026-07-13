import 'package:cloud_firestore/cloud_firestore.dart';

class DentistModel {
  const DentistModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.description,
    required this.image,
    required this.workingDays,
    required this.workingHours,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  final String id;
  final String name;
  final String specialization;
  final int experience;
  final String description;
  final String image;
  final List<String> workingDays;
  final Map<String, String> workingHours;
  final double averageRating;
  final int totalReviews;

  factory DentistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DentistModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      specialization: data['specialization'] as String? ?? '',
      experience: (data['experience'] as num?)?.toInt() ?? 0,
      description: data['description'] as String? ?? '',
      image: data['image'] as String? ?? '',
      workingDays: List<String>.from(data['workingDays'] as List? ?? []),
      workingHours: Map<String, String>.from(
        data['workingHours'] as Map? ?? {'start': '09:00', 'end': '17:00'},
      ),
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (data['totalReviews'] as num?)?.toInt() ?? 0,
    );
  }

  factory DentistModel.fromMap(Map<String, dynamic> data, String id) {
    return DentistModel(
      id: id,
      name: data['name'] as String? ?? '',
      specialization: data['specialization'] as String? ?? '',
      experience: (data['experience'] as num?)?.toInt() ?? 0,
      description: data['description'] as String? ?? '',
      image: data['image'] as String? ?? '',
      workingDays: List<String>.from(data['workingDays'] as List? ?? []),
      workingHours: Map<String, String>.from(
        data['workingHours'] as Map? ?? {'start': '09:00', 'end': '17:00'},
      ),
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (data['totalReviews'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialization': specialization,
      'experience': experience,
      'description': description,
      'image': image,
      'workingDays': workingDays,
      'workingHours': workingHours,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }

  DentistModel copyWith({
    String? id,
    String? name,
    String? specialization,
    int? experience,
    String? description,
    String? image,
    List<String>? workingDays,
    Map<String, String>? workingHours,
    double? averageRating,
    int? totalReviews,
  }) {
    return DentistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      experience: experience ?? this.experience,
      description: description ?? this.description,
      image: image ?? this.image,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  bool isWorkingOn(String dayName) {
    final lower = dayName.toLowerCase();
    return workingDays.any((d) => d.toLowerCase() == lower);
  }

  String get workStartTime => workingHours['start'] ?? '09:00';
  String get workEndTime => workingHours['end'] ?? '17:00';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DentistModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
