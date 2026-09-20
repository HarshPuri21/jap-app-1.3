import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../services/route_observer.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import 'test_run_screen.dart';

class TestSetupScreen extends StatefulWidget {
  const TestSetupScreen({super.key});

  @override
  State<TestSetupScreen> createState() => _TestSetupScreenState();
}

class _TestSetupScreenState extends State<TestSetupScreen> with RouteAware {
  String _qtype = 'sentences'; // sentences | kanji | radicals | mixed
  String _difficulty = 'all'; // all | easy | normal | hard
  double _count = 15;

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
    // Returning here after "Try Another Test" pops the results screen off.
    context.read<AudioService>().ensureMenuMusicPlaying();
  }

  void _click() => context.read<AudioService>().playMenuClick();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    _sectionLabel('What do you want to be tested on?'),
                    const SizedBox(height: 10),
                    _segmented(
                      value: _qtype,
                      options: const [
                        ('sentences', 'Sentences'),
                        ('kanji', 'Kanji'),
                        ('radicals', 'Radicals'),
                        ('mixed', 'Mixed'),
                      ],
                      onChanged: (v) {
                        _click();
                        setState(() => _qtype = v);
                      },
                    ),
                    const SizedBox(height: 28),
                    _sectionLabel('Difficulty'),
                    const SizedBox(height: 10),
                    _segmented(
                      value: _difficulty,
                      options: const [
                        ('all', 'All'),
                        ('easy', 'Easy'),
                        ('normal', 'Normal'),
                        ('hard', 'Hard'),
                      ],
                      onChanged: (v) {
                        _click();
                        setState(() => _difficulty = v);
                      },
                    ),
                    const SizedBox(height: 28),
                    _sectionLabel('Number of questions: ${_count.round()}'),
                    Slider(
                      value: _count,
                      min: 5,
                      max: 50,
                      divisions: 9,
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.cardBorder,
                      label: '${_count.round()}',
                      onChanged: (v) => setState(() => _count = v),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _click();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TestRunScreen(
                            qtype: _qtype,
                            difficulty: _difficulty,
                            count: _count.round(),
                          ),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('Start Test'),
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

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.fg,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _segmented({
    required String value,
    required List<(String, String)> options,
    required ValueChanged<String> onChanged,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((o) {
        final selected = o.$1 == value;
        return GestureDetector(
          onTap: () => onChanged(o.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accent.withOpacity(0.2)
                  : AppColors.bgCard.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.accent : AppColors.cardBorder,
                width: 1.4,
              ),
            ),
            child: Text(
              o.$2,
              style: TextStyle(
                color: selected ? AppColors.accent : AppColors.fg,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),
        );
      }).toList(),
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
              _click();
              Navigator.of(context).pop();
            },
          ),
          const Expanded(
            child: Text(
              'Take a Test',
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
