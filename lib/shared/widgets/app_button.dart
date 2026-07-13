import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !isLoading && onPressed != null;

    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final size = Size(width ?? double.infinity, height);

    switch (variant) {
      case AppButtonVariant.primary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: isEnabled ? onPressed : null,
            child: child,
          ),
        );

      case AppButtonVariant.secondary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              minimumSize: size,
            ),
            onPressed: isEnabled ? onPressed : null,
            child: child,
          ),
        );

      case AppButtonVariant.outlined:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: isEnabled ? onPressed : null,
            child: child,
          ),
        );

      case AppButtonVariant.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          child: child,
        );
    }
  }
}
