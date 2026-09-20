import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sentence.dart';
import '../services/data_service.dart';
import '../services/settings_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/breakdown_panel.dart';
import '../widgets/difficulty_badge.dart';
import '../widgets/option_button.dart';

class SentenceModeScreen extends StatefulWidget {
  const SentenceModeScreen({super.key});

  @override
  State<SentenceModeScreen> createState() => _SentenceModeScreenState();
}

class _SentenceModeScreenState extends State<SentenceModeScreen> {
  String _difficulty = 'all';
  late List<Sentence> _deck;
  int _index = 0;
  String? _selected;
  int _score = 0;
  int _answered = 0;

  @override
  void initState() {
    super.initState();
    _reload();
    // Lesson screens are always freshly created on entry, so a plain
    // initState call (unlike a menu screen returned to via pop) is enough.
    context.read<AudioService>().stopMenuMusic();
  }

  void _reload() {
    _deck = DataService.instance.drawSentences(_difficulty, 0);
    _index = 0;
    _selected = null;
    _score = 0;
    _answered = 0;
  }

  Sentence get _current => _deck[_index];

  void _choose(String option) {
    if (_selected != null) return;
    final correct = option == _current.answer;
    setState(() {
      _selected = option;
      _answered += 1;
      if (correct) _score += 1;
    });
    final audio = context.read<AudioService>();
    if (correct) {
      audio.playLessonClick();
    } else {
      audio.playError();
    }
    context.read<SettingsService>().recordAnswer(correct: correct);
  }

  void _next() {
    context.read<AudioService>().playLessonClick();
    setState(() {
      if (_index < _deck.length - 1) {
        _index += 1;
      } else {
        _deck.shuffle();
        _index = 0;
      }
      _selected = null;
    });
  }

  void _setDifficulty(String diff) {
    context.read<AudioService>().playLessonClick();
    setState(() {
      _difficulty = diff;
      _reload();
    });
  }

  OptionState _stateFor(String option) {
    if (_selected == null) return OptionState.idle;
    if (option == _current.answer) return OptionState.selectedCorrect;
    if (option == _selected) return OptionState.selectedWrong;
    return OptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    if (_deck.isEmpty) {
      return Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No sentences found for "$_difficulty" difficulty.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.fgMuted),
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

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) < -200) _next();
            },
            child: Column(
              children: [
                _buildAppBar(context),
                _buildDifficultyChips(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DifficultyBadge(difficulty: _current.difficulty),
                            Text(
                              '${_index + 1} / ${_deck.length}',
                              style: const TextStyle(
                                  color: AppColors.fgMuted, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 26),
                          alignment: Alignment.center,
                          child: Text(
                            _current.jp,
                            textAlign: TextAlign.center,
                            style: AppTheme.jp(30, weight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._current.options.map(
                          (opt) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OptionButton(
                              text: opt,
                              state: _stateFor(opt),
                              onTap: () => _choose(opt),
                            ),
                          ),
                        ),
                        if (_selected != null) ...[
                          _buildFeedback(),
                          const SizedBox(height: 8),
                          BreakdownPanel(chunks: _current.breakdown),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    final correct = _selected == _current.answer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            correct ? Icons.check_circle : Icons.cancel,
            color: correct ? AppColors.good : AppColors.bad,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            correct ? 'Correct!' : 'Not quite — correct answer highlighted',
            style: TextStyle(
              color: correct ? AppColors.good : AppColors.bad,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
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
              'Learn Sentences',
              style: TextStyle(
                color: AppColors.fg,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            'Score: $_score/$_answered',
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

  Widget _buildDifficultyChips() {
    const options = ['all', 'easy', 'normal', 'hard'];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: options.map((d) {
          final selected = d == _difficulty;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(d == 'all' ? 'All' : d.toUpperCase()),
              selected: selected,
              onSelected: (_) => _setDifficulty(d),
              selectedColor: AppColors.accent.withOpacity(0.25),
              backgroundColor: AppColors.bgCard.withOpacity(0.6),
              labelStyle: TextStyle(
                color: selected ? AppColors.accent : AppColors.fgMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: selected ? AppColors.accent : AppColors.cardBorder,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _next,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.fgMuted,
                side: const BorderSide(color: AppColors.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Skip ⏭'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _selected == null ? null : _next,
              child: const Text('Next →'),
            ),
          ),
        ],
      ),
    );
  }
}
