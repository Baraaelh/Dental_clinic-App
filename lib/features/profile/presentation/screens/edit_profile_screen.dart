import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmNewPasswordCtrl = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameCtrl.text = user.name;
      _phoneCtrl.text = user.phone;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmNewPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await AppHelpers.showImageSourceSheet(
      context,
      onSourceSelected: (source) async {
        final file = await AppHelpers.pickImage(source);
        if (file != null) {
          setState(() => _imageFile = File(file.path));
        }
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(profileControllerProvider.notifier).updateProfile(
            uid: user.uid,
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            imageFile: _imageFile,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).profileUpdated),
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

  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context);
    if (_currentPasswordCtrl.text.isEmpty || _newPasswordCtrl.text.isEmpty) return;
    if (_newPasswordCtrl.text != _confirmNewPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordsDoNotMatch),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(profileControllerProvider.notifier).changePassword(
            currentPassword: _currentPasswordCtrl.text,
            newPassword: _newPasswordCtrl.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.passwordChanged),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _currentPasswordCtrl.clear();
        _newPasswordCtrl.clear();
        _confirmNewPasswordCtrl.clear();
        setState(() => _isChangingPassword = false);
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
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l10n.editProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    _imageFile != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: FileImage(_imageFile!),
                          )
                        : AvatarWidget(
                            imageUrl: user?.profileImage,
                            name: user?.name,
                            radius: 50,
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: l10n.fullName,
                controller: _nameCtrl,
                prefixIcon: const Icon(Icons.person_outline),
                validator: (v) => Validators.validateName(v),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.phoneNumber,
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                validator: (v) => Validators.validatePhone(v),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: l10n.save,
                onPressed: _saveProfile,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.changePassword,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(
                      _isChangingPassword ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: () =>
                        setState(() => _isChangingPassword = !_isChangingPassword),
                  ),
                ],
              ),
              if (_isChangingPassword) ...[
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.currentPassword,
                  controller: _currentPasswordCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.newPassword,
                  controller: _newPasswordCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.confirmNewPassword,
                  controller: _confirmNewPasswordCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: l10n.changePassword,
                  onPressed: _changePassword,
                  isLoading: _isLoading,
                  variant: AppButtonVariant.outlined,
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
