import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_progress.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';

class ReviewResultsScreen extends StatelessWidget {
  final Map<Rating, int> tally;

  const ReviewResultsScreen({super.key, required this.tally});

  int get _total => tally.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final total = _total;
    final again = tally[Rating.again] ?? 0;
    final hard = tally[Rating.hard] ?? 0;
    final good = tally[Rating.good] ?? 0;
    final easy = tally[Rating.easy] ?? 0;
    final smooth = total == 0 ? 0 : (100 * (good + easy) / total).round();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✅', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text(
                  'Review complete — $total item${total == 1 ? '' : 's'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.fg,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                if (total > 0)
                  Text(
                    '$smooth% remembered smoothly',
                    style: const TextStyle(
                        color: AppColors.fgMuted, fontSize: 13.5),
                  ),
                const SizedBox(height: 26),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Again', again, AppColors.bad),
                      _stat('Hard', hard, AppColors.warn),
                      _stat('Good', good, AppColors.good),
                      _stat('Easy', easy, AppColors.accent),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<AudioService>().playMenuClick();
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.fg,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: AppColors.fgMuted, fontSize: 11)),
      ],
    );
  }
}
