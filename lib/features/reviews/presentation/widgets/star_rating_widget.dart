import 'package:flutter/material.dart';
import '../../../../shared/widgets/rating_bar.dart';
import '../../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    switch (_rating.toInt()) {
      case 1:
        return l10n.ratingPoor;
      case 2:
        return l10n.ratingFair;
      case 3:
        return l10n.ratingGood;
      case 4:
        return l10n.ratingVeryGood;
      case 5:
        return l10n.ratingExcellent;
      default:
        return l10n.tapToRate;
    }
  }
}
