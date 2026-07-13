import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle _poppins({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? AppColors.textPrimary,
        height: height,
      );

  static TextStyle _cairo({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? AppColors.textPrimary,
        height: height,
      );

  static TextStyle getHeadline1(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? _cairo(fontSize: 28, fontWeight: FontWeight.w700)
        : _poppins(fontSize: 28, fontWeight: FontWeight.w700);
  }

  static TextStyle getHeadline2(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? _cairo(fontSize: 22, fontWeight: FontWeight.w700)
        : _poppins(fontSize: 22, fontWeight: FontWeight.w700);
  }

  static TextStyle getHeadline3(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? _cairo(fontSize: 18, fontWeight: FontWeight.w600)
        : _poppins(fontSize: 18, fontWeight: FontWeight.w600);
  }

  static TextStyle getBody(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? _cairo(fontSize: 14)
        : _poppins(fontSize: 14);
  }

  static TextStyle getBodyMedium(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? _cairo(fontSize: 14, fontWeight: FontWeight.w500)
        : _poppins(fontSize: 14, fontWeight: FontWeight.w500);
  }

  static TextStyle getCaption(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? _cairo(fontSize: 12, color: AppColors.textSecondary)
        : _poppins(fontSize: 12, color: AppColors.textSecondary);
  }

  static TextStyle getButton(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return isAr
        ? _cairo(fontSize: 16, fontWeight: FontWeight.w600)
        : _poppins(fontSize: 16, fontWeight: FontWeight.w600);
  }

  static TextTheme getTextTheme(bool isArabic) {
    if (isArabic) {
      return TextTheme(
        displayLarge: _cairo(fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: _cairo(fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: _cairo(fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge: _cairo(fontSize: 32, fontWeight: FontWeight.w700),
        headlineMedium: _cairo(fontSize: 28, fontWeight: FontWeight.w700),
        headlineSmall: _cairo(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: _cairo(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: _cairo(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: _cairo(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: _cairo(fontSize: 16),
        bodyMedium: _cairo(fontSize: 14),
        bodySmall: _cairo(fontSize: 12),
        labelLarge: _cairo(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: _cairo(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: _cairo(fontSize: 11),
      );
    }
    return TextTheme(
      displayLarge: _poppins(fontSize: 57, fontWeight: FontWeight.w400),
      displayMedium: _poppins(fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: _poppins(fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge: _poppins(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: _poppins(fontSize: 28, fontWeight: FontWeight.w700),
      headlineSmall: _poppins(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: _poppins(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: _poppins(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: _poppins(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: _poppins(fontSize: 16),
      bodyMedium: _poppins(fontSize: 14),
      bodySmall: _poppins(fontSize: 12),
      labelLarge: _poppins(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: _poppins(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: _poppins(fontSize: 11),
    );
  }
}
