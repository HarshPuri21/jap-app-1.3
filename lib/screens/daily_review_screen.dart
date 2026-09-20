import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_progress.dart';
import '../models/vocab_entry.dart';
import '../models/kanji_entry.dart';
import '../services/progress_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/rating_buttons.dart';
import 'review_results_screen.dart';

class DailyReviewScreen extends StatefulWidget {
  const DailyReviewScreen({super.key});

  @override
  State<DailyReviewScreen> createState() => _DailyReviewScreenState();
}

class _DailyReviewScreenState extends State<DailyReviewScreen> {
  late List<String> _queue;
  int _index = 0;
  bool _flipped = false;
  bool _busy = false; // guards against double-tapping a rating button

  final Map<Rating, int> _tally = {
    Rating.again: 0,
    Rating.hard: 0,
    Rating.good: 0,
    Rating.easy: 0,
  };

  @override
  void initState() {
    super.initState();
    _queue = context.read<ProgressService>().buildDailyQueue();
    context.read<AudioService>().stopMenuMusic();
  }

  String get _currentId => _queue[_index];

  Future<void> _rate(Rating rating) async {
    if (_busy) return; // prevents a double-tap from recording twice
    setState(() => _busy = true);
    context.read<AudioService>().playLessonClick();

    await context.read<ProgressService>().rate(_currentId, rating);
    _tally[rating] = (_tally[rating] ?? 0) + 1;

    if (!mounted) return;

    if (_index >= _queue.length - 1) {
      context.read<AudioService>().ensureMenuMusicPlaying();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReviewResultsScreen(tally: Map.of(_tally)),
        ),
      );
      return;
    }

    setState(() {
      _index += 1;
      _flipped = false;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty) {
      return _buildEmptyState(context);
    }

    final progressService = context.read<ProgressService>();
    final itemId = _currentId;
    final item = progressService.resolveItem(itemId);
    final existingProgress = progressService.progressFor(itemId);
    final previewSource = existingProgress ?? ItemProgress();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ((_index) / _queue.length).clamp(0, 1).toDouble(),
                    minHeight: 6,
                    backgroundColor: AppColors.bgCard,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
              ),
              Expanded(
                child: item == null
                    ? const Center(
                        child: Text(
                          'This item is no longer available.',
                          style: TextStyle(color: AppColors.fgMuted),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: GestureDetector(
                          onTap: () {
                            context.read<AudioService>().playLessonClick();
                            setState(() => _flipped = !_flipped);
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: _buildCard(item, key: ValueKey(_flipped)),
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: _flipped
                    ? RatingButtons(
                        previewFrom: previewSource,
                        enabled: !_busy,
                        onRate: _rate,
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AudioService>().playLessonClick();
                            setState(() => _flipped = true);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text('Show Answer'),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(dynamic item, {Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      child: item is VocabEntry
          ? _vocabFace(item)
          : _kanjiFace(item as KanjiEntry),
    );
  }

  Widget _vocabFace(VocabEntry v) {
    if (!_flipped) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(v.jp, style: AppTheme.jp(52, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(v.kana,
              style: AppTheme.jp(20).copyWith(color: AppColors.fgMuted)),
          const SizedBox(height: 20),
          const Text('Tap to reveal meaning',
              style: TextStyle(color: AppColors.fgMuted, fontSize: 12)),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(v.jp, style: AppTheme.jp(30, weight: FontWeight.w700)),
        const SizedBox(height: 14),
        Text(v.meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 24,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text(v.romaji,
            style: const TextStyle(color: AppColors.fgMuted, fontSize: 14)),
      ],
    );
  }

  Widget _kanjiFace(KanjiEntry k) {
    if (!_flipped) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(k.kanji,
              style: AppTheme.jp(90, weight: FontWeight.w700)
                  .copyWith(color: AppColors.accent)),
          const SizedBox(height: 20),
          const Text('Tap to reveal meaning',
              style: TextStyle(color: AppColors.fgMuted, fontSize: 12)),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(k.kanji,
            style: AppTheme.jp(56, weight: FontWeight.w700)
                .copyWith(color: AppColors.accent)),
        const SizedBox(height: 14),
        Text(k.meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 22,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (k.onyomi.isNotEmpty)
          Text('On: ${k.onyomi.join("、")}',
              style: AppTheme.jp(15).copyWith(color: AppColors.fg)),
        if (k.kunyomi.isNotEmpty)
          Text('Kun: ${k.kunyomi.join("、")}',
              style: AppTheme.jp(15).copyWith(color: AppColors.fg)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 18),
                      const Text(
                        "You're all caught up!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.fg,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No reviews due right now. Check back later, or '
                        'browse Flashcards to get ahead.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.fgMuted, fontSize: 13.5),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<AudioService>().playLessonClick();
                            context.read<AudioService>().ensureMenuMusicPlaying();
                            Navigator.of(context).pop();
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.fg),
            onPressed: () {
              context.read<AudioService>().playLessonClick();
              context.read<AudioService>().ensureMenuMusicPlaying();
              Navigator.of(context).pop();
            },
          ),
          const Expanded(
            child: Text(
              'Daily Review',
              style: TextStyle(
                color: AppColors.fg,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (_queue.isNotEmpty)
            Text(
              '${_index + 1} / ${_queue.length}',
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }
}
