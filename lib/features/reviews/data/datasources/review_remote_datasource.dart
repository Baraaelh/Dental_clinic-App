import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/models/review_model.dart';

class ReviewRemoteDatasource {
  ReviewRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.reviewsCollection);

  Future<List<ReviewModel>> getDentistReviews(String dentistId) async {
    try {
      final snapshot = await _collection
          .where('dentistId', isEqualTo: dentistId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(ReviewModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to load reviews: $e');
    }
  }

  Future<List<ReviewModel>> getAllReviews() async {
    try {
      final snapshot = await _collection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(ReviewModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException('Failed to load reviews: $e');
    }
  }

  Future<String> addReview(ReviewModel review) async {
    try {
      final ref = await _collection.add(review.toMap());

      // Recalculate dentist's average rating
      final allReviews = await getDentistReviews(review.dentistId);
      final total = allReviews.length + 1;
      final sum =
          allReviews.fold<double>(0, (a, r) => a + r.rating) + review.rating;
      final avg = sum / total;

      await _firestore
          .collection(AppConstants.dentistsCollection)
          .doc(review.dentistId)
          .update({'averageRating': avg, 'totalReviews': total});

      return ref.id;
    } catch (e) {
      throw ServerException('Failed to add review: $e');
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return;

      final review = ReviewModel.fromFirestore(doc);
      await _collection.doc(id).delete();

      // Recalculate dentist rating
      final remaining = await getDentistReviews(review.dentistId);
      if (remaining.isEmpty) {
        await _firestore
            .collection(AppConstants.dentistsCollection)
            .doc(review.dentistId)
            .update({'averageRating': 0.0, 'totalReviews': 0});
      } else {
        final sum = remaining.fold<double>(0, (a, r) => a + r.rating);
        final avg = sum / remaining.length;
        await _firestore
            .collection(AppConstants.dentistsCollection)
            .doc(review.dentistId)
            .update({
          'averageRating': avg,
          'totalReviews': remaining.length,
        });
      }
    } catch (e) {
      throw ServerException('Failed to delete review: $e');
    }
  }

  Future<bool> hasPatientReviewed(String patientId, String dentistId) async {
    try {
      final snapshot = await _collection
          .where('patientId', isEqualTo: patientId)
          .where('dentistId', isEqualTo: dentistId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasCompletedAppointment(
      String patientId, String dentistId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.appointmentsCollection)
          .where('patientId', isEqualTo: patientId)
          .where('dentistId', isEqualTo: dentistId)
          .where('status', isEqualTo: AppConstants.statusCompleted)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<Map<int, int>> getRatingBreakdown(String dentistId) async {
    try {
      final reviews = await getDentistReviews(dentistId);
      final breakdown = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final r in reviews) {
        final star = r.rating.round().clamp(1, 5);
        breakdown[star] = (breakdown[star] ?? 0) + 1;
      }
      return breakdown;
    } catch (_) {
      return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    }
  }
}
