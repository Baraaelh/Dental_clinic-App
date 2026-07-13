import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../dentists/presentation/controllers/dentist_controller.dart';
import '../controllers/review_controller.dart';
import '../widgets/star_rating_widget.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  const WriteReviewScreen({super.key, required this.dentistId});
  final String dentistId;

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentCtrl = TextEditingController();
  double _rating = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(submitReviewProvider.notifier).submit(
            patientId: user.uid,
            patientName: user.name,
            patientImage: user.profileImage,
            dentistId: widget.dentistId,
            rating: _rating,
            comment: _commentCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).reviewSubmitted),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dentistAsync = ref.watch(dentistDetailProvider(widget.dentistId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l10n.writeReview),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dentistAsync.when(
                data: (dentist) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dentist.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            dentist.specialization,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox(height: 60),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  l10n.yourRating,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: StarRatingWidget(
                  onRatingChanged: (r) => setState(() => _rating = r),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.yourComment,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: '',
                hint: l10n.commentHint,
                controller: _commentCtrl,
                maxLines: 5,
                minLines: 3,
                validator: (v) => Validators.validateComment(
                  v,
                  requiredMsg: l10n.commentRequired,
                  shortMsg: l10n.commentTooShort,
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: l10n.submit,
                onPressed: _submit,
                isLoading: _isLoading,
                icon: Icons.star,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
