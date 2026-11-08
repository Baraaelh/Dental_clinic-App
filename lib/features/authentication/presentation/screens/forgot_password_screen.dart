import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/errors/error_messages.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(_emailCtrl.text.trim());
      if (mounted) {
        setState(() => _emailSent = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.errorMessage(e)),
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(l10n.forgotPasswordTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessView(l10n) : _buildFormView(l10n),
        ),
      ),
    );
  }

  Widget _buildFormView(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.forgotPasswordTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.forgotPasswordSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: l10n.email,
            hint: l10n.emailHint,
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.email_outlined),
            onSubmitted: (_) => _sendResetEmail(),
            validator: (v) => Validators.validateEmail(
              v,
              requiredMsg: l10n.emailRequired,
              invalidMsg: l10n.emailInvalid,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: l10n.sendResetEmail,
            onPressed: _sendResetEmail,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 80, color: AppColors.success),
        const SizedBox(height: 24),
        Text(
          l10n.success,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.resetEmailSent,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 32),
        AppButton(
          label: l10n.back,
          onPressed: () => Navigator.pop(context),
          variant: AppButtonVariant.outlined,
        ),
      ],
    );
  }
}
