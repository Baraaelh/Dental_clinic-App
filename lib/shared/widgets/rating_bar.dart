import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RatingBar extends StatelessWidget {
  const RatingBar({
    super.key,
    required this.rating,
    this.size = 18,
    this.color = AppColors.star,
    this.itemCount = 5,
  });

  final double rating;
  final double size;
  final Color color;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        final filled = index < rating.floor();
        final partial = !filled && index < rating;

        return Icon(
          filled
              ? Icons.star
              : partial
                  ? Icons.star_half
                  : Icons.star_border,
          size: size,
          color: color,
        );
      }),
    );
  }
}

class InteractiveRatingBar extends StatefulWidget {
  const InteractiveRatingBar({
    super.key,
    required this.onRatingChanged,
    this.initialRating = 0,
    this.size = 40,
    this.color = AppColors.star,
    this.itemCount = 5,
  });

  final void Function(double rating) onRatingChanged;
  final double initialRating;
  final double size;
  final Color color;
  final int itemCount;

  @override
  State<InteractiveRatingBar> createState() => _InteractiveRatingBarState();
}

class _InteractiveRatingBarState extends State<InteractiveRatingBar> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.itemCount, (index) {
        return GestureDetector(
          onTap: () {
            setState(() => _rating = index + 1.0);
            widget.onRatingChanged(_rating);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(4),
            child: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              size: index < _rating ? widget.size * 1.1 : widget.size,
              color: widget.color,
            ),
          ),
        );
      }),
    );
  }
}
