import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class AppHelpers {
  const AppHelpers._();

  static List<String> generateTimeSlots({
    String start = AppConstants.workStartTime,
    String end = AppConstants.workEndTime,
    int slotDuration = AppConstants.slotDurationMinutes,
  }) {
    final slots = <String>[];
    final startParts = start.split(':');
    final endParts = end.split(':');

    var current = DateTime(
      2000,
      1,
      1,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );
    final endTime = DateTime(
      2000,
      1,
      1,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    while (current.isBefore(endTime)) {
      slots.add(DateFormat('HH:mm').format(current));
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
                title: const Text('From Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  onSourceSelected(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('From Camera'),
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

  static String formatFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'weak-password':
        return 'Password is too weak';
      case 'requires-recent-login':
        return 'Please re-authenticate to complete this action';
      default:
        return 'Authentication failed. Please try again';
    }
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
