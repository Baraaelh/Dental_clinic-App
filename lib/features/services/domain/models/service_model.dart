import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String image;

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      image: data['image'] as String? ?? '',
    );
  }

  factory ServiceModel.fromMap(Map<String, dynamic> data, String id) {
    return ServiceModel(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      image: data['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'image': image,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? image,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
