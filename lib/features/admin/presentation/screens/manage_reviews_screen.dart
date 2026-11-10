import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../reviews/domain/models/review_model.dart';
import '../../../reviews/presentation/controllers/review_controller.dart';
import '../../../../core/errors/error_messages.dart';

class ManageReviewsScreen extends ConsumerWidget {
  const ManageReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reviewsAsync = ref.watch(allReviewsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageReviews)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allReviewsProvider),
        child: reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return EmptyStateWidget(
                message: l10n.noReviews,
                icon: Icons.star_border,
              );
            }
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return _AdminReviewTile(
                  review: review,
                  onDelete: () => _deleteReview(context, ref, review.id, l10n),
                );
              },
            );
          },
          loading: () => const ShimmerListView(itemCount: 6, itemHeight: 120),
          error: (e, _) => AppErrorWidget(
            message: context.errorMessage(e),
            onRetry: () => ref.invalidate(allReviewsProvider),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteReview(BuildContext context, WidgetRef ref,
      String reviewId, AppLocalizations l10n) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.deleteReview,
      message: l10n.deleteReviewConfirm,
      confirmLabel: l10n.delete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(deleteReviewProvider.notifier).delete(reviewId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reviewDeleted),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.errorMessage(e)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _AdminReviewTile extends ConsumerWidget {
  const _AdminReviewTile({required this.review, required this.onDelete});

  final ReviewModel review;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleteState = ref.watch(deleteReviewProvider);
    final isDeleting =
        deleteState.isLoading;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: review.patientImage.isNotEmpty
                      ? CachedNetworkImageProvider(review.patientImage)
                      : null,
                  child: review.patientImage.isEmpty
                      ? Text(
                          review.patientName.isNotEmpty
                              ? review.patientName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.patientName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (review.createdAt != null)
                        Text(
                          DateFormat('MMM dd, yyyy').format(review.createdAt!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                if (isDeleting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
