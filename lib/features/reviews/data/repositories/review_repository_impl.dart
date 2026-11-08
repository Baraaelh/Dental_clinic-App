import '../../domain/models/review_model.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._datasource);
  final ReviewRemoteDatasource _datasource;

  @override
  Future<List<ReviewModel>> getDentistReviews(String dentistId) =>
      _datasource.getDentistReviews(dentistId);

  @override
  Future<List<ReviewModel>> getAllReviews() => _datasource.getAllReviews();

  @override
  Future<String> addReview(ReviewModel review) => _datasource.addReview(review);

  @override
  Future<void> deleteReview(String id) => _datasource.deleteReview(id);

  @override
  Future<bool> hasPatientReviewed(String patientId, String dentistId) =>
      _datasource.hasPatientReviewed(patientId, dentistId);

  @override
  Future<bool> hasCompletedAppointment(String patientId, String dentistId) =>
      _datasource.hasCompletedAppointment(patientId, dentistId);

  @override
  Future<String?> getCompletedAppointmentId(String patientId, String dentistId) =>
      _datasource.getCompletedAppointmentId(patientId, dentistId);

  @override
  Future<Map<int, int>> getRatingBreakdown(String dentistId) =>
      _datasource.getRatingBreakdown(dentistId);
}
