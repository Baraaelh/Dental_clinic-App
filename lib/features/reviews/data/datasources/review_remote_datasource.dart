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

  /// One review per patient per dentist.
  static String reviewIdFor(String patientId, String dentistId) =>
      '${patientId}_$dentistId';

  /// Saves the review and updates the dentist's rating in one transaction.
  /// Firestore rules check both writes together, so a patient can only bump
  /// the rating by exactly the value of the review they are creating.
  Future<String> addReview(ReviewModel review) async {
    final reviewRef =
        _collection.doc(reviewIdFor(review.patientId, review.dentistId));
    final dentistRef = _firestore
        .collection(AppConstants.dentistsCollection)
        .doc(review.dentistId);

    try {
      await _firestore.runTransaction((tx) async {
        final existing = await tx.get(reviewRef);
        if (existing.exists) {
          throw const ValidationException('You have already reviewed this dentist');
        }
        final dentist = await tx.get(dentistRef);
        if (!dentist.exists) throw const NotFoundException('Dentist not found');

        final data = dentist.data()!;
        final oldTotal = (data['totalReviews'] as num?) ?? 0;
        // Older dentist documents have no ratingSum; derive it the same way
        // the security rules do.
        final oldSum = (data['ratingSum'] as num?) ??
            ((data['averageRating'] as num?) ?? 0) * oldTotal;
        final newTotal = oldTotal + 1;
        final newSum = oldSum + review.rating;

        tx.set(reviewRef, review.toMap());
        tx.update(dentistRef, {
          'ratingSum': newSum,
          'totalReviews': newTotal,
          'averageRating': newSum / newTotal,
        });
      });
      return reviewRef.id;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to add review: $e');
    }
  }

  /// Admin only. Recomputes the dentist's rating from the remaining reviews.
  Future<void> deleteReview(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return;

      final review = ReviewModel.fromFirestore(doc);
      await _collection.doc(id).delete();

      final remaining = await getDentistReviews(review.dentistId);
      final sum = remaining.fold<double>(0, (a, r) => a + r.rating);
      await _firestore
          .collection(AppConstants.dentistsCollection)
          .doc(review.dentistId)
          .update({
        'ratingSum': sum,
        'totalReviews': remaining.length,
        'averageRating': remaining.isEmpty ? 0.0 : sum / remaining.length,
      });
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
          String patientId, String dentistId) async =>
      await getCompletedAppointmentId(patientId, dentistId) != null;

  /// Id of a completed appointment between this patient and dentist, if any.
  Future<String?> getCompletedAppointmentId(
      String patientId, String dentistId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.appointmentsCollection)
          .where('patientId', isEqualTo: patientId)
          .where('dentistId', isEqualTo: dentistId)
          .where('status', isEqualTo: AppConstants.statusCompleted)
          .limit(1)
          .get();
      return snapshot.docs.isEmpty ? null : snapshot.docs.first.id;
    } catch (_) {
      return null;
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
