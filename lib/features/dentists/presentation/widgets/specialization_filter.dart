import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class SpecializationFilter extends StatelessWidget {
  const SpecializationFilter({
    super.key,
    required this.specializations,
    required this.selected,
    required this.onSelected,
  });

  final List<String> specializations;
  final String selected;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final all = [l10n.all, ...specializations];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = all[index];
          final isSelected = selected == item || (selected.isEmpty && index == 0);
          return FilterChip(
            label: Text(item),
            selected: isSelected,
            onSelected: (_) => onSelected(index == 0 ? '' : item),
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          );
        },
      ),
    );
  }
}
