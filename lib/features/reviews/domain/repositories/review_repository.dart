import '../models/review_model.dart';

abstract class ReviewRepository {
  Future<List<ReviewModel>> getDentistReviews(String dentistId);
  Future<List<ReviewModel>> getAllReviews();
  Future<String> addReview(ReviewModel review);
  Future<void> deleteReview(String id);
  Future<bool> hasPatientReviewed(String patientId, String dentistId);
  Future<bool> hasCompletedAppointment(String patientId, String dentistId);
  Future<Map<int, int>> getRatingBreakdown(String dentistId);
}
