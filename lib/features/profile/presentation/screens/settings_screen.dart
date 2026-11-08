import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/config/app_config.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: l10n.appearance),
          SwitchListTile(
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(isDark ? l10n.darkMode : l10n.lightMode),
            value: isDark,
            activeThumbColor: AppColors.primary,
            onChanged: (value) {
              ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          const Divider(),
          _SectionHeader(title: l10n.language),
          RadioGroup<String>(
            groupValue: locale.languageCode,
            onChanged: (v) {
              if (v != null) {
                ref.read(localeProvider.notifier).setLocale(Locale(v));
              }
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.language, color: AppColors.secondary, size: 20),
                  ),
                  title: Text(l10n.english),
                  value: 'en',
                ),
                RadioListTile<String>(
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'ع',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  title: Text(l10n.arabic),
                  value: 'ar',
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${AppLocalizations.of(context).appName} v${AppConfig.appVersion}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
