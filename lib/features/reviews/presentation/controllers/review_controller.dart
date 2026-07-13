import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/review_remote_datasource.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/models/review_model.dart';
import '../../domain/repositories/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(ReviewRemoteDatasource());
});

final dentistReviewsProvider =
    FutureProviderFamily<List<ReviewModel>, String>((ref, dentistId) {
  return ref.read(reviewRepositoryProvider).getDentistReviews(dentistId);
});

final allReviewsProvider = FutureProvider<List<ReviewModel>>((ref) {
  return ref.read(reviewRepositoryProvider).getAllReviews();
});

final ratingBreakdownProvider =
    FutureProviderFamily<Map<int, int>, String>((ref, dentistId) {
  return ref.read(reviewRepositoryProvider).getRatingBreakdown(dentistId);
});

final canReviewProvider = FutureProviderFamily<
    ({bool canReview, bool alreadyReviewed}),
    ({String patientId, String dentistId})>((ref, params) async {
  final repo = ref.read(reviewRepositoryProvider);
  final hasCompleted =
      await repo.hasCompletedAppointment(params.patientId, params.dentistId);
  final alreadyReviewed =
      await repo.hasPatientReviewed(params.patientId, params.dentistId);
  return (canReview: hasCompleted && !alreadyReviewed, alreadyReviewed: alreadyReviewed);
});

final submitReviewProvider =
    AsyncNotifierProvider<SubmitReviewController, void>(SubmitReviewController.new);

class SubmitReviewController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit({
    required String patientId,
    required String patientName,
    required String patientImage,
    required String dentistId,
    required double rating,
    required String comment,
  }) async {
    state = const AsyncLoading();
    try {
      final review = ReviewModel(
        id: '',
        patientId: patientId,
        patientName: patientName,
        patientImage: patientImage,
        dentistId: dentistId,
        rating: rating,
        comment: comment,
      );
      await ref.read(reviewRepositoryProvider).addReview(review);
      ref.invalidate(dentistReviewsProvider(dentistId));
      ref.invalidate(ratingBreakdownProvider(dentistId));
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final deleteReviewProvider =
    AsyncNotifierProvider<DeleteReviewController, void>(DeleteReviewController.new);

class DeleteReviewController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> delete(String reviewId) async {
    state = const AsyncLoading();
    try {
      await ref.read(reviewRepositoryProvider).deleteReview(reviewId);
      ref.invalidate(allReviewsProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
