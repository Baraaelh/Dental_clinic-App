import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../controllers/review_controller.dart';
import '../widgets/rating_breakdown_widget.dart';
import '../widgets/review_card.dart';
import '../../../../core/errors/error_messages.dart';

class ReviewsListScreen extends ConsumerWidget {
  const ReviewsListScreen({super.key, required this.dentistId});
  final String dentistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reviewsAsync = ref.watch(dentistReviewsProvider(dentistId));
    final breakdownAsync = ref.watch(ratingBreakdownProvider(dentistId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reviews),
        actions: [
          if (currentUser != null && !currentUser.isAdmin)
            Consumer(
              builder: (context, ref, _) {
                if (currentUser.uid.isEmpty) return const SizedBox.shrink();
                final canReviewAsync = ref.watch(canReviewProvider((
                  patientId: currentUser.uid,
                  dentistId: dentistId,
                )));
                return canReviewAsync.when(
                  data: (data) => data.canReview
                      ? TextButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: Text(l10n.writeReview),
                          onPressed: () =>
                              context.push('/write-review/$dentistId'),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
        ],
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return EmptyStateWidget(
              message: l10n.noReviews,
              icon: Icons.star_border,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              breakdownAsync.when(
                data: (breakdown) => RatingBreakdownWidget(
                  breakdown: breakdown,
                  total: reviews.length,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              ...reviews.map((r) => ReviewCard(review: r)),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(
          message: context.errorMessage(e),
          onRetry: () => ref.refresh(dentistReviewsProvider(dentistId)),
        ),
      ),
    );
  }
}
