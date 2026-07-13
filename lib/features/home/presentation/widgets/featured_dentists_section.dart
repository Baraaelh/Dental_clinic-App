import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/rating_bar.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../dentists/presentation/controllers/dentist_controller.dart';

class FeaturedDentistsSection extends ConsumerWidget {
  const FeaturedDentistsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dentistsAsync = ref.watch(featuredDentistsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.featuredDentists,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.go('/dentists'),
                child: Text(l10n.viewAll),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: dentistsAsync.when(
            data: (dentists) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: dentists.length,
              itemBuilder: (context, index) {
                final dentist = dentists[index];
                return GestureDetector(
                  onTap: () => context.push('/dentists/${dentist.id}'),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Hero(
                            tag: 'dentist-${dentist.id}',
                            child: dentist.image.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: dentist.image,
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      height: 110,
                                      alignment: Alignment.center,
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      child: const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      height: 110,
                                      alignment: Alignment.center,
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      child: const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 110,
                                    alignment: Alignment.center,
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    child: const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dentist.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dentist.specialization,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  RatingBar(
                                    rating: dentist.averageRating,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dentist.averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => ShimmerLoading(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 3,
                itemBuilder: (_, __) => Container(
                  width: 150,
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
