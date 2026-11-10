import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launch(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).somethingWentWrong;
    var opened = false;
    try {
      opened = await url_launcher.launchUrl(
        Uri.parse(url),
        mode: url_launcher.LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    // e.g. no phone or email app installed: tell the user instead of
    // silently doing nothing.
    if (!opened) {
      messenger.showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final items = [
      (
        icon: Icons.phone,
        label: l10n.callUs,
        value: AppConfig.clinicPhone,
        color: AppColors.success,
        url: 'tel:${AppConfig.clinicPhone}',
      ),
      (
        icon: Icons.chat,
        label: l10n.whatsapp,
        value: '+${AppConfig.clinicWhatsApp}',
        color: const Color(0xFF25D366),
        url: 'https://wa.me/${AppConfig.clinicWhatsApp}',
      ),
      (
        icon: Icons.email,
        label: l10n.emailUs,
        value: AppConfig.clinicEmail,
        color: AppColors.primary,
        url: 'mailto:${AppConfig.clinicEmail}',
      ),
      (
        icon: Icons.location_on,
        label: l10n.location,
        value: AppConfig.clinicAddress,
        color: AppColors.error,
        url:
            'https://maps.google.com/?q=${AppConfig.clinicLatitude},${AppConfig.clinicLongitude}',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l10n.contactUs),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradient1, AppColors.gradient2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_hospital, color: Colors.white, size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    AppConfig.clinicName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppConfig.clinicAddress,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...items.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _launch(context, item.url),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: item.color),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
