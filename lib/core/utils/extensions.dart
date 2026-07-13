import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

extension StringExtensions on String {
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get initials {
    final parts = trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get isValidEmail {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(trim());
  }
}

extension DateTimeExtensions on DateTime {
  String toDisplayDate() => DateFormat('MMM dd, yyyy').format(this);

  String toDisplayTime() => DateFormat('hh:mm a').format(this);

  String toDisplayDateTime() => DateFormat('MMM dd, yyyy hh:mm a').format(this);

  String toFirestoreDate() => DateFormat('yyyy-MM-dd').format(this);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool get isToday => isSameDay(DateTime.now());

  bool get isTomorrow => isSameDay(DateTime.now().add(const Duration(days: 1)));

  String get dayName => DateFormat('EEEE').format(this);
}

extension AppointmentStatusExtensions on String {
  Color get statusColor {
    switch (this) {
      case AppConstants.statusPending:
        return AppColors.statusPending;
      case AppConstants.statusApproved:
        return AppColors.statusApproved;
      case AppConstants.statusRejected:
        return AppColors.statusRejected;
      case AppConstants.statusCompleted:
        return AppColors.statusCompleted;
      case AppConstants.statusCancelled:
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get statusIcon {
    switch (this) {
      case AppConstants.statusPending:
        return Icons.schedule;
      case AppConstants.statusApproved:
        return Icons.check_circle;
      case AppConstants.statusRejected:
        return Icons.cancel;
      case AppConstants.statusCompleted:
        return Icons.done_all;
      case AppConstants.statusCancelled:
        return Icons.block;
      default:
        return Icons.help;
    }
  }
}

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

extension DoubleExtensions on double {
  String get formatted => NumberFormat('#,##0.##').format(this);
  String get currency => 'SAR ${NumberFormat('#,##0.##').format(this)}';
}
