import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../services/progress_service.dart';
import '../services/audio_service.dart';
import '../services/route_observer.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/mode_card.dart';
import 'sentence_mode_screen.dart';
import 'kanji_mode_screen.dart';
import 'flashcard_screen.dart';
import 'test_setup_screen.dart';
import 'settings_screen.dart';
import 'daily_review_screen.dart';
import 'radical_list_screen.dart';
import 'radical_quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    // Covers the very first appearance (app launch) -- subsequent returns
    // from a lesson screen are covered by didPopNext below, since popping
    // back to an already-built screen does not re-run initState.
    context.read<AudioService>().ensureMenuMusicPlaying();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // We're visible again after a pushed screen (a lesson, settings, etc.)
    // was popped off -- resume the menu music if it isn't already playing.
    context.read<AudioService>().ensureMenuMusicPlaying();
  }

  void _openScreen(Widget screen) {
    context.read<AudioService>().playMenuClick();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final progress = context.watch<ProgressService>();
    final answered = settings.statsAnsweredTotal;
    final correct = settings.statsCorrectTotal;
    final pct = answered == 0 ? null : (100 * correct / answered).round();
    final queueSize = progress.todayQueueSize;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Nihongo Trainer',
                        style: TextStyle(
                          color: AppColors.fg,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: AppColors.fgMuted),
                      onPressed: () => _openScreen(const SettingsScreen()),
                    ),
                  ],
                ),
                const Text(
                  '日本語トレーニング',
                  style: TextStyle(
                    color: AppColors.fgMuted,
                    fontFamily: kJpFontFamily,
                    fontSize: 15,
                  ),
                ),
                if (pct != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_outlined,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Overall: $correct / $answered correct ($pct%)',
                          style: const TextStyle(
                            color: AppColors.fg,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _ReviewBanner(
                  queueSize: queueSize,
                  onTap: () => _openScreen(const DailyReviewScreen()),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView(
                    children: [
                      ModeCard(
                        icon: Icons.chat_bubble_outline,
                        title: 'Learn Sentences',
                        subtitle: '320 example sentences, easy → hard',
                        onTap: () =>
                            _openScreen(const SentenceModeScreen()),
                      ),
                      const SizedBox(height: 14),
                      ModeCard(
                        icon: Icons.brush_outlined,
                        title: 'Learn Kanji',
                        subtitle: '536 kanji with readings & breakdowns',
                        onTap: () => _openScreen(const KanjiModeScreen()),
                      ),
                      const SizedBox(height: 14),
                      ModeCard(
                        icon: Icons.style_outlined,
                        title: 'Flashcards',
                        subtitle: 'Swipe through vocab & kanji',
                        onTap: () => _openScreen(const FlashcardScreen()),
                      ),
                      const SizedBox(height: 14),
                      ModeCard(
                        icon: Icons.category_outlined,
                        title: 'Radicals',
                        subtitle: '280 radicals — browse & search',
                        onTap: () => _openScreen(const RadicalListScreen()),
                      ),
                      const SizedBox(height: 14),
                      ModeCard(
                        icon: Icons.extension_outlined,
                        title: 'Radical Quiz',
                        subtitle: 'Match each radical to its meaning',
                        onTap: () => _openScreen(const RadicalQuizScreen()),
                      ),
                      const SizedBox(height: 14),
                      ModeCard(
                        icon: Icons.quiz_outlined,
                        title: 'Take a Test',
                        subtitle: 'Timed quiz with a final score',
                        onTap: () => _openScreen(const TestSetupScreen()),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The prominent "what should I do today" entry point -- sits above the
/// regular mode list since it's the recommended daily habit, styled a
/// notch brighter than the plain ModeCards below it to draw the eye first.
class _ReviewBanner extends StatelessWidget {
  final int queueSize;
  final VoidCallback onTap;
  const _ReviewBanner({required this.queueSize, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasReviews = queueSize > 0;
    return Material(
      color: hasReviews
          ? AppColors.accent.withOpacity(0.16)
          : AppColors.bgCard.withOpacity(0.7),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasReviews ? AppColors.accent : AppColors.cardBorder,
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: hasReviews
                      ? AppColors.accent.withOpacity(0.28)
                      : AppColors.good.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  hasReviews ? Icons.bolt : Icons.check_circle_outline,
                  color: hasReviews ? AppColors.accent : AppColors.good,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasReviews
                          ? 'Daily Review — $queueSize due'
                          : 'Daily Review',
                      style: const TextStyle(
                        color: AppColors.fg,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasReviews
                          ? 'Vocab & kanji due for review, spaced just right'
                          : "You're all caught up — check back later",
                      style: const TextStyle(
                        color: AppColors.fgMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.fgMuted),
            ],
          ),
        ),
      ),
    );
  }
}
