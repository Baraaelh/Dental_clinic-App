import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../dentists/domain/models/dentist_model.dart';
import '../../../dentists/presentation/controllers/dentist_controller.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/utils/status_labels.dart';

class AddEditDentistScreen extends ConsumerStatefulWidget {
  const AddEditDentistScreen({super.key, this.dentistId});
  final String? dentistId;

  @override
  ConsumerState<AddEditDentistScreen> createState() =>
      _AddEditDentistScreenState();
}

class _AddEditDentistScreenState extends ConsumerState<AddEditDentistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _specializationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController(text: '09:00');
  final _endTimeCtrl = TextEditingController(text: '17:00');

  List<String> _selectedDays = [];
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  bool get _isEditing => widget.dentistId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadDentist();
  }

  Future<void> _loadDentist() async {
    final dentist = await ref
        .read(dentistRepositoryProvider)
        .getDentistById(widget.dentistId!);
    _nameCtrl.text = dentist.name;
    _specializationCtrl.text = dentist.specialization;
    _experienceCtrl.text = dentist.experience.toString();
    _descriptionCtrl.text = dentist.description;
    _startTimeCtrl.text = dentist.workStartTime;
    _endTimeCtrl.text = dentist.workEndTime;
    setState(() {
      _selectedDays = List.from(dentist.workingDays);
      _existingImageUrl = dentist.image;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specializationCtrl.dispose();
    _experienceCtrl.dispose();
    _descriptionCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    await AppHelpers.showImageSourceSheet(
      context,
      onSourceSelected: (source) async {
        final file = await AppHelpers.pickImage(source);
        if (file != null) setState(() => _imageFile = File(file.path));
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).selectAtLeastOneWorkingDay),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      String imageUrl = _existingImageUrl ?? '';

      if (_imageFile != null) {
        final uid = DateTime.now().millisecondsSinceEpoch.toString();
        final path = StorageService.instance.generatePath(
          AppConstants.storageDentistImages,
          uid,
          'jpg',
        );
        imageUrl = await StorageService.instance.uploadFile(
          file: _imageFile!,
          path: path,
        );
      }

      final dentist = DentistModel(
        id: widget.dentistId ?? '',
        name: _nameCtrl.text.trim(),
        specialization: _specializationCtrl.text.trim(),
        experience: int.tryParse(_experienceCtrl.text.trim()) ?? 0,
        description: _descriptionCtrl.text.trim(),
        image: imageUrl,
        workingDays: _selectedDays,
        workingHours: {
          'start': _startTimeCtrl.text,
          'end': _endTimeCtrl.text,
        },
      );

      if (_isEditing) {
        await ref.read(dentistRepositoryProvider).updateDentist(dentist);
        await ref.read(dentistListProvider.notifier).refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.dentistUpdated),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await ref.read(dentistRepositoryProvider).addDentist(dentist);
        await ref.read(dentistListProvider.notifier).refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.dentistAdded),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context);
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
        title: Text(_isEditing ? l10n.editDentist : l10n.addDentist),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(_imageFile!,
                                    fit: BoxFit.cover),
                              )
                            : _existingImageUrl != null &&
                                    _existingImageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: _existingImageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const Icon(
                                        Icons.person,
                                        size: 48,
                                        color: AppColors.primary,
                                      ),
                                      errorWidget: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 48,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: l10n.fullName,
                controller: _nameCtrl,
                validator: Validators.validateRequired,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.specialization,
                controller: _specializationCtrl,
                validator: Validators.validateRequired,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.experience,
                controller: _experienceCtrl,
                keyboardType: TextInputType.number,
                validator: Validators.validateRequired,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.description,
                hint: l10n.descriptionHint,
                controller: _descriptionCtrl,
                maxLines: 4,
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.selectWorkingDays,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.weekDays.map((day) {
                  final selected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(weekdayLabel(AppLocalizations.of(context), day)),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: l10n.startTime,
                      controller: _startTimeCtrl,
                      readOnly: true,
                      onTap: () => _selectTime(context, _startTimeCtrl),
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      label: l10n.endTime,
                      controller: _endTimeCtrl,
                      readOnly: true,
                      onTap: () => _selectTime(context, _endTimeCtrl),
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AppButton(
                label: _isEditing ? l10n.update : l10n.add,
                onPressed: _save,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController ctrl) async {
    final parts = ctrl.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }
}
