import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
    this.icon,
  });

  final String title;
  final String message;
  /// Defaults to the translated "Confirm" / "Cancel".
  final String? confirmLabel;
  final String? cancelLabel;
  final bool isDestructive;
  final IconData? icon;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final confirmColor = isDestructive ? AppColors.error : AppColors.primary;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: confirmColor),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel ?? AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel ?? AppLocalizations.of(context).confirm),
        ),
      ],
    );
  }
}
