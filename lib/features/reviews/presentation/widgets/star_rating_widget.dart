import 'package:flutter/material.dart';
import '../../../../shared/widgets/rating_bar.dart';

class StarRatingWidget extends StatefulWidget {
  const StarRatingWidget({
    super.key,
    required this.onRatingChanged,
    this.initialRating = 0,
  });

  final void Function(double) onRatingChanged;
  final double initialRating;

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InteractiveRatingBar(
          initialRating: _rating,
          size: 44,
          onRatingChanged: (r) {
            setState(() => _rating = r);
            widget.onRatingChanged(r);
          },
        ),
        const SizedBox(height: 8),
        Text(
          _getRatingLabel(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.amber.shade700,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _getRatingLabel() {
    switch (_rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap to rate';
    }
  }
}
