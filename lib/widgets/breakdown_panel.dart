import 'package:flutter/material.dart';
import '../models/sentence.dart';
import '../theme/app_theme.dart';

class BreakdownPanel extends StatelessWidget {
  final List<BreakdownChunk> chunks;
  const BreakdownPanel({super.key, required this.chunks});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: chunks.map((c) => _row(c)).toList(),
      ),
    );
  }

  Widget _row(BreakdownChunk c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              c.chunk,
              style: AppTheme.jp(18, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.reading != null && c.reading!.isNotEmpty)
                  Text(
                    c.reading!,
                    style: const TextStyle(
                      color: AppColors.fgMuted,
                      fontSize: 12.5,
                    ),
                  ),
                if (c.meaning != null && c.meaning!.isNotEmpty)
                  Text(
                    c.meaning!,
                    style: const TextStyle(color: AppColors.fg, fontSize: 14),
                  ),
                if (c.note != null && c.note!.isNotEmpty)
                  Text(
                    c.note!,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
