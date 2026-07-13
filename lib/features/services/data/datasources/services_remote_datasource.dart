import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/service_model.dart';

class ServicesRemoteDatasource {
  ServicesRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.servicesCollection);

  Future<List<ServiceModel>> getServices() async {
    try {
      final snapshot = await _collection.orderBy('title').get();
      return snapshot.docs.map(ServiceModel.fromFirestore).toList();
    } catch (e) {
      debugPrint('getServices error: $e');
      throw ServerException('Failed to load services: $e');
    }
  }

  Future<ServiceModel> getServiceById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) throw const NotFoundException('Service not found');
      return ServiceModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Failed to load service: $e');
    }
  }

  Future<String> addService(ServiceModel service) async {
    try {
      final ref = await _collection.add(service.toMap());
      return ref.id;
    } catch (e) {
      throw ServerException('Failed to add service: $e');
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      await _collection.doc(service.id).update(service.toMap());
    } catch (e) {
      throw ServerException('Failed to update service: $e');
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete service: $e');
    }
  }
}
