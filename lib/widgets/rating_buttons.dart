import 'package:flutter/material.dart';
import '../models/item_progress.dart';
import '../theme/app_theme.dart';

class RatingButtons extends StatelessWidget {
  final ItemProgress previewFrom;
  final ValueChanged<Rating> onRate;
  final bool enabled;

  const RatingButtons({
    super.key,
    required this.previewFrom,
    required this.onRate,
    this.enabled = true,
  });

  static const _specs = [
    (Rating.again, 'Again', AppColors.bad),
    (Rating.hard, 'Hard', AppColors.warn),
    (Rating.good, 'Good', AppColors.good),
    (Rating.easy, 'Easy', AppColors.accent),
  ];

  String _formatDays(int days) => days >= 30
      ? '${(days / 30).round()}mo'
      : (days == 1 ? '1d' : '${days}d');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _specs.map((spec) {
        final (rating, label, color) = spec;
        final preview = previewFrom.previewIntervalDays(rating);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: enabled ? () => onRate(rating) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.6)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDays(preview),
                        style: TextStyle(
                          color: color.withOpacity(0.85),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
