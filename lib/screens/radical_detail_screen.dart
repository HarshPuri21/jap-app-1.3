import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/radical_entry.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/difficulty_badge.dart';

class RadicalDetailScreen extends StatelessWidget {
  final RadicalEntry radical;
  const RadicalDetailScreen({super.key, required this.radical});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: DifficultyBadge(difficulty: radical.difficulty),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 26),
                        alignment: Alignment.center,
                        child: Text(
                          radical.char,
                          style: AppTheme.jp(96, weight: FontWeight.w700)
                              .copyWith(color: AppColors.accent),
                        ),
                      ),
                      Text(
                        radical.meaning,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.fg,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        radical.name,
                        textAlign: TextAlign.center,
                        style: AppTheme.jp(16).copyWith(
                          color: AppColors.fgMuted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _infoCard(
                        title: 'Usage',
                        child: Text(
                          radical.usage,
                          style: const TextStyle(
                              color: AppColors.fg, fontSize: 14, height: 1.4),
                        ),
                      ),
                      if (radical.examples.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _infoCard(
                          title:
                              'Example kanji (${radical.examples.length})',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: radical.examples
                                .map((ex) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 56,
                                            child: Text(ex.kanji,
                                                style: AppTheme.jp(26,
                                                    weight:
                                                        FontWeight.w700)),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(ex.reading,
                                                    style: AppTheme
                                                        .jp(13)
                                                        .copyWith(
                                                            color: AppColors
                                                                .fgMuted)),
                                                Text(ex.meaning,
                                                    style: const TextStyle(
                                                        color:
                                                            AppColors.fg,
                                                        fontSize: 14)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required Widget child}) {
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
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.fgMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.fg),
            onPressed: () {
              context.read<AudioService>().playLessonClick();
              Navigator.of(context).pop();
            },
          ),
          const Expanded(
            child: Text(
              'Radical Detail',
              style: TextStyle(
                color: AppColors.fg,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
