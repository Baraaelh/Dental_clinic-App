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
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../services/domain/models/service_model.dart';
import '../../../services/presentation/controllers/services_controller.dart';
import '../../../../core/errors/error_messages.dart';

class ManageServicesScreen extends ConsumerWidget {
  const ManageServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageServices)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(servicesProvider.notifier).refresh(),
        child: servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return EmptyStateWidget(
                message: l10n.noServices,
                icon: Icons.medical_services_outlined,
                action: () => _showAddEditSheet(context, ref, null),
                actionLabel: l10n.addService,
              );
            }
            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _ServiceTile(
                  service: service,
                  onEdit: () => _showAddEditSheet(context, ref, service),
                  onDelete: () => _deleteService(context, ref, service.id, l10n),
                );
              },
            );
          },
          loading: () => const ShimmerListView(itemCount: 6),
          error: (e, _) => AppErrorWidget(
            message: context.errorMessage(e),
            onRetry: () => ref.read(servicesProvider.notifier).refresh(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditSheet(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditSheet(
      BuildContext context, WidgetRef ref, ServiceModel? service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddEditServiceSheet(service: service, ref: ref),
    );
  }

  Future<void> _deleteService(BuildContext context, WidgetRef ref,
      String serviceId, AppLocalizations l10n) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.deleteService,
      message: l10n.deleteServiceConfirm,
      confirmLabel: l10n.delete,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(servicesProvider.notifier).deleteService(serviceId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.serviceDeleted),
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

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: service.image.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: service.image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 56,
                    height: 56,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.medical_services,
                        color: AppColors.primary),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.medical_services,
                        color: AppColors.primary),
                  ),
                )
              : Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.medical_services,
                      color: AppColors.primary),
                ),
        ),
        title: Text(service.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '\$${service.price.toStringAsFixed(2)}',
          style: const TextStyle(color: AppColors.primary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEditServiceSheet extends StatefulWidget {
  const _AddEditServiceSheet({required this.service, required this.ref});

  final ServiceModel? service;
  final WidgetRef ref;

  @override
  State<_AddEditServiceSheet> createState() => _AddEditServiceSheetState();
}

class _AddEditServiceSheetState extends State<_AddEditServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  bool get _isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.service?.title ?? '');
    _descCtrl =
        TextEditingController(text: widget.service?.description ?? '');
    _priceCtrl = TextEditingController(
        text: widget.service?.price.toStringAsFixed(2) ?? '');
    _existingImageUrl = widget.service?.image;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
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
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);
    try {
      String imageUrl = _existingImageUrl ?? '';

      if (_imageFile != null) {
        final uid = DateTime.now().millisecondsSinceEpoch.toString();
        final path = StorageService.instance.generatePath(
          AppConstants.storageServiceImages,
          uid,
          'jpg',
        );
        imageUrl = await StorageService.instance.uploadFile(
          file: _imageFile!,
          path: path,
        );
      }

      final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
      final service = ServiceModel(
        id: widget.service?.id ?? '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: price,
        image: imageUrl,
      );

      if (_isEditing) {
        await widget.ref.read(servicesProvider.notifier).updateService(service);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.serviceUpdated),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        await widget.ref.read(servicesProvider.notifier).addService(service);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.serviceAdded),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isEditing ? l10n.editService : l10n.addService,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : _existingImageUrl != null &&
                                    _existingImageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: _existingImageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const Icon(
                                        Icons.medical_services,
                                        size: 36,
                                        color: AppColors.primary,
                                      ),
                                      errorWidget: (_, __, ___) => const Icon(
                                        Icons.medical_services,
                                        size: 36,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.medical_services,
                                    size: 36,
                                    color: AppColors.primary,
                                  ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.serviceName,
                controller: _titleCtrl,
                validator: Validators.validateRequired,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: l10n.description,
                controller: _descCtrl,
                maxLines: 3,
                validator: Validators.validateRequired,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: l10n.price,
                controller: _priceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validatePrice,
                prefixIcon: const Icon(Icons.attach_money),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: _isEditing ? l10n.update : l10n.add,
                onPressed: _save,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
