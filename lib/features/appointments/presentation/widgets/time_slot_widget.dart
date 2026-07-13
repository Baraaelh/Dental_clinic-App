import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TimeSlotWidget extends StatelessWidget {
  const TimeSlotWidget({
    super.key,
    required this.time,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
  });

  final String time;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isBooked) {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade400;
      borderColor = Colors.grey.shade200;
    } else if (isSelected) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
      borderColor = AppColors.primary;
    } else {
      bgColor = AppColors.primary.withValues(alpha: 0.05);
      textColor = AppColors.primary;
      borderColor = AppColors.primary.withValues(alpha: 0.3);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: isBooked ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            time,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
