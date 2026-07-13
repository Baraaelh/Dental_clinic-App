import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).register(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
      if (!mounted) return;
      _showVerificationDialog();
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

  void _showVerificationDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.verifyEmailTitle),
        content: Text(l10n.verifyEmailMessage),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.register,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signUp,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: l10n.fullName,
                  hint: l10n.fullNameHint,
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline),
                  autofillHints: const [AutofillHints.name],
                  validator: (v) => Validators.validateName(
                    v,
                    requiredMsg: l10n.nameRequired,
                    shortMsg: l10n.nameTooShort,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.email,
                  hint: l10n.emailHint,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  autofillHints: const [AutofillHints.email],
                  validator: (v) => Validators.validateEmail(
                    v,
                    requiredMsg: l10n.emailRequired,
                    invalidMsg: l10n.emailInvalid,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.phoneNumber,
                  hint: l10n.phoneNumberHint,
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: (v) => Validators.validatePhone(
                    v,
                    requiredMsg: l10n.phoneRequired,
                    invalidMsg: l10n.phoneInvalid,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.password,
                  hint: l10n.passwordHint,
                  controller: _passwordCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (v) => Validators.validatePassword(
                    v,
                    requiredMsg: l10n.passwordRequired,
                    shortMsg: l10n.passwordTooShort,
                    uppercaseMsg: l10n.passwordNeedsUppercase,
                    numberMsg: l10n.passwordNeedsNumber,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.confirmPassword,
                  hint: l10n.confirmPasswordHint,
                  controller: _confirmPasswordCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  onSubmitted: (_) => _register(),
                  validator: (v) => Validators.validateConfirmPassword(
                    v,
                    _passwordCtrl.text,
                    mismatchMsg: l10n.passwordsDoNotMatch,
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: l10n.signUp,
                  onPressed: _register,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.haveAccount),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          l10n.signIn,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
