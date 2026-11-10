import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';

class AppHelpers {
  const AppHelpers._();

  /// Parses "HH:mm" (also "H:mm"). Returns null for anything else.
  static DateTime? _parseTime(String value) {
    final m = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*$').firstMatch(value);
    if (m == null) return null;
    final h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    if (h > 23 || min > 59) return null;
    return DateTime(2000, 1, 1, h, min);
  }

  /// Bookable slot start times between [start] and [end].
  /// Returns an empty list (instead of throwing) when the working hours
  /// stored for a dentist are missing or malformed.
  static List<String> generateTimeSlots({
    String start = AppConstants.workStartTime,
    String end = AppConstants.workEndTime,
    int slotDuration = AppConstants.slotDurationMinutes,
  }) {
    final slots = <String>[];
    var current = _parseTime(start);
    final endTime = _parseTime(end);
    if (current == null || endTime == null || slotDuration <= 0) return slots;

    while (current!.isBefore(endTime)) {
      // Always Latin digits: slot times are parsed and used in Firestore ids.
      slots.add('${current.hour.toString().padLeft(2, '0')}:'
          '${current.minute.toString().padLeft(2, '0')}');
      current = current.add(Duration(minutes: slotDuration));
    }
    return slots;
  }

  static Future<XFile?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    return picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
  }

  static Future<void> showImageSourceSheet(
    BuildContext context, {
    required void Function(ImageSource source) onSourceSelected,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(ctx).fromGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  onSourceSelected(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(AppLocalizations.of(ctx).fromCamera),
                onTap: () {
                  Navigator.pop(ctx);
                  onSourceSelected(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  static bool isUpcomingStatus(String status) {
    return status == AppConstants.statusPending || status == AppConstants.statusApproved;
  }

  static bool isHistoryStatus(String status) {
    return status == AppConstants.statusCompleted ||
        status == AppConstants.statusRejected ||
        status == AppConstants.statusCancelled;
  }

  static String getDayAbbreviation(String day) {
    switch (day) {
      case 'Monday':
        return 'Mon';
      case 'Tuesday':
        return 'Tue';
      case 'Wednesday':
        return 'Wed';
      case 'Thursday':
        return 'Thu';
      case 'Friday':
        return 'Fri';
      case 'Saturday':
        return 'Sat';
      case 'Sunday':
        return 'Sun';
      default:
        return day.substring(0, 3);
    }
  }
}
