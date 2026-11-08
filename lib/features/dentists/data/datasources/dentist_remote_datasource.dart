import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/dentist_model.dart';

class DentistRemoteDatasource {
  DentistRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.dentistsCollection);

  Future<List<DentistModel>> getDentists({
    int limit = 10,
    DocumentSnapshot? lastDoc,
    String? specialization,
    String? searchQuery,
  }) async {
    try {
      // When a specialization filter is active, combining it with orderBy('name')
      // would require a composite index. Instead, fetch by specialization only
      // and sort in Dart to avoid that requirement.
      if (specialization != null && specialization.isNotEmpty) {
        final snapshot = await _collection
            .where('specialization', isEqualTo: specialization)
            .get();
        var dentists = snapshot.docs.map(DentistModel.fromFirestore).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          dentists = dentists
              .where((d) =>
                  d.name.toLowerCase().contains(q) ||
                  d.specialization.toLowerCase().contains(q))
              .toList();
        }
        return dentists.take(limit).toList();
      }

      // No specialization filter — orderBy on a single field uses the
      // automatic single-field index, so no composite index is needed.
      Query<Map<String, dynamic>> query =
          _collection.orderBy('name').limit(limit);
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      var dentists = snapshot.docs.map(DentistModel.fromFirestore).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        dentists = dentists
            .where((d) =>
                d.name.toLowerCase().contains(q) ||
                d.specialization.toLowerCase().contains(q))
            .toList();
      }

      return dentists;
    } catch (e) {
      debugPrint('getDentists error: $e');
      throw ServerException('Failed to load dentists: $e');
    }
  }

  Future<DentistModel> getDentistById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) throw const NotFoundException('Dentist not found');
      return DentistModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Failed to load dentist: $e');
    }
  }

  Future<List<DentistModel>> getFeaturedDentists(int count) async {
    try {
      final snapshot = await _collection
          .orderBy('averageRating', descending: true)
          .limit(count)
          .get();
      return snapshot.docs.map(DentistModel.fromFirestore).toList();
    } catch (e) {
      debugPrint('getFeaturedDentists error: $e');
      throw ServerException('Failed to load featured dentists: $e');
    }
  }

  Future<List<String>> getSpecializations() async {
    try {
      final snapshot = await _collection.get();
      final specializations = snapshot.docs
          .map((d) => d.data()['specialization'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      return specializations;
    } catch (e) {
      debugPrint('getSpecializations error: $e');
      throw ServerException('Failed to load specializations: $e');
    }
  }

  Future<String> addDentist(DentistModel dentist) async {
    try {
      final ref = await _collection.add({...dentist.toMap(), 'ratingSum': 0.0});
      return ref.id;
    } catch (e) {
      throw ServerException('Failed to add dentist: $e');
    }
  }

  Future<void> updateDentist(DentistModel dentist) async {
    try {
      // Rating fields are maintained by reviews; don't overwrite them with
      // possibly stale values from the edit form.
      await _collection.doc(dentist.id).update(dentist.toMap()
        ..remove('averageRating')
        ..remove('totalReviews'));
    } catch (e) {
      throw ServerException('Failed to update dentist: $e');
    }
  }

  Future<void> deleteDentist(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete dentist: $e');
    }
  }

  Future<void> updateDentistRating(
      String id, double rating, int totalReviews) async {
    try {
      await _collection.doc(id).update({
        'averageRating': rating,
        'totalReviews': totalReviews,
      });
    } catch (e) {
      throw ServerException('Failed to update dentist rating: $e');
    }
  }
}
