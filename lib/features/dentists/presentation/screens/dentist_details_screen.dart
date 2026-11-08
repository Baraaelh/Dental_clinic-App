import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/rating_bar.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../reviews/presentation/controllers/review_controller.dart';
import '../../../reviews/presentation/widgets/review_card.dart';
import '../controllers/dentist_controller.dart';
import '../widgets/working_hours_widget.dart';
import '../../../../core/errors/error_messages.dart';

class DentistDetailsScreen extends ConsumerWidget {
  const DentistDetailsScreen({super.key, required this.dentistId});
  final String dentistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dentistAsync = ref.watch(dentistDetailProvider(dentistId));

    return Scaffold(
      body: dentistAsync.when(
        data: (dentist) {
          final currentUser = ref.watch(currentUserProvider);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                leading: const BackButton(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'dentist-$dentistId',
                    child: dentist.image.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: dentist.image,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.person,
                                size: 80,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.person,
                              size: 80,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dentist.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dentist.specialization,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  dentist.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                RatingBar(
                                    rating: dentist.averageRating, size: 12),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.totalReviews(dentist.totalReviews),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.work_outline,
                        label:
                            '${dentist.experience} ${l10n.experienceYears(dentist.experience)}',
                        color: AppColors.secondary,
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        l10n.about,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dentist.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                      ),
                      const SizedBox(height: 24),
                      WorkingHoursWidget(dentist: dentist),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.reviews,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push('/reviews/$dentistId'),
                            child: Text(l10n.viewAll),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _ReviewsSection(dentistId: dentistId),
                      const SizedBox(height: 24),
                      if (currentUser != null && !currentUser.isAdmin)
                        AppButton(
                          label: l10n.bookAppointment,
                          onPressed: () =>
                              context.push('/book/$dentistId'),
                          icon: Icons.calendar_today,
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: AppErrorWidget(
            message: context.errorMessage(e),
            onRetry: () => ref.refresh(dentistDetailProvider(dentistId)),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({required this.dentistId});
  final String dentistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reviewsAsync = ref.watch(dentistReviewsProvider(dentistId));

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                l10n.noReviews,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        final limited = reviews.take(5).toList();
        return Column(
          children: limited
              .map((r) => ReviewCard(review: r))
              .toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
