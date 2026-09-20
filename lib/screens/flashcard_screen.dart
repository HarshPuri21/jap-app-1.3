import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vocab_entry.dart';
import '../models/kanji_entry.dart';
import '../models/item_progress.dart';
import '../services/data_service.dart';
import '../services/progress_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';

enum _CardKind { vocab, kanji }

class _Card {
  final _CardKind kind;
  final VocabEntry? vocab;
  final KanjiEntry? kanji;
  _Card.vocab(this.vocab)
      : kind = _CardKind.vocab,
        kanji = null;
  _Card.kanji(this.kanji)
      : kind = _CardKind.kanji,
        vocab = null;

  /// Stable ID used to key this card's SRS progress record.
  String get itemId => kind == _CardKind.vocab
      ? vocabItemId(vocab!.jp)
      : kanjiItemId(kanji!.kanji);
}

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late List<_Card> _deck;
  final PageController _controller = PageController();
  final Set<int> _flipped = {};
  String _filter = 'mixed'; // 'mixed' | 'vocab' | 'kanji'
  int _known = 0;
  int _seen = 0;

  @override
  void initState() {
    super.initState();
    _buildDeck();
    context.read<AudioService>().stopMenuMusic();
  }

  void _buildDeck() {
    final vocabCards =
        DataService.instance.vocab.map((v) => _Card.vocab(v)).toList();
    final kanjiCards =
        DataService.instance.kanjiEntries.map((k) => _Card.kanji(k)).toList();
    switch (_filter) {
      case 'vocab':
        _deck = vocabCards;
        break;
      case 'kanji':
        _deck = kanjiCards;
        break;
      default:
        _deck = [...vocabCards, ...kanjiCards];
    }
    _deck.shuffle();
    _flipped.clear();
    _known = 0;
    _seen = 0;
    _advancing = false;
  }

  void _setFilter(String f) {
    context.read<AudioService>().playLessonClick();
    setState(() {
      _filter = f;
      _buildDeck();
    });
    if (_controller.hasClients) _controller.jumpToPage(0);
  }

  void _toggleFlip(int index) {
    context.read<AudioService>().playLessonClick();
    setState(() {
      if (_flipped.contains(index)) {
        _flipped.remove(index);
      } else {
        _flipped.add(index);
      }
    });
  }

  bool _advancing = false; // guards a fast double-swipe from counting twice

  void _markAndAdvance(int index, bool known) {
    if (_advancing) return;
    _advancing = true;
    context.read<AudioService>().playLessonClick();
    setState(() {
      _seen += 1;
      if (known) _known += 1;
    });
    // Swipe up ("know it") records as a "Good" review; swipe down ("still
    // learning") records as "Again" -- the same persisted SRS state the
    // dedicated Daily Review screen uses, so flashcard swipes here count
    // for real, not just a session tally that resets when you leave.
    context
        .read<ProgressService>()
        .rate(_deck[index].itemId, known ? Rating.good : Rating.again);

    final next = (_controller.page ?? 0).round() + 1;
    if (next < _deck.length) {
      _controller
          .nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      )
          .then((_) {
        if (mounted) _advancing = false;
      });
    } else {
      _advancing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildFilterChips(),
              const SizedBox(height: 8),
              Expanded(
                child: _deck.isEmpty
                    ? const Center(
                        child: Text('No cards',
                            style: TextStyle(color: AppColors.fgMuted)))
                    : PageView.builder(
                        controller: _controller,
                        itemCount: _deck.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            child: GestureDetector(
                              onTap: () => _toggleFlip(index),
                              onVerticalDragEnd: (d) {
                                if ((d.primaryVelocity ?? 0) < -250) {
                                  _markAndAdvance(
                                      index, true); // swipe up = know it
                                } else if ((d.primaryVelocity ?? 0) > 250) {
                                  _markAndAdvance(index,
                                      false); // swipe down = still learning
                                }
                              },
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                        opacity: anim, child: child),
                                child: _buildCardFace(
                                  _deck[index],
                                  _flipped.contains(index),
                                  key: ValueKey(
                                      '$index-${_flipped.contains(index)}'),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              _buildHint(),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace(_Card card, bool flipped, {Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(28),
      child: Center(
        child: card.kind == _CardKind.vocab
            ? _vocabFace(card.vocab!, flipped)
            : _kanjiFace(card.kanji!, flipped),
      ),
    );
  }

  Widget _vocabFace(VocabEntry v, bool flipped) {
    if (!flipped) {
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
        Text(v.meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 26,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text(v.romaji,
            style: const TextStyle(color: AppColors.fgMuted, fontSize: 14)),
        const SizedBox(height: 6),
        Text(v.category,
            style: const TextStyle(color: AppColors.fgMuted, fontSize: 12)),
      ],
    );
  }

  Widget _kanjiFace(KanjiEntry k, bool flipped) {
    if (!flipped) {
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
        Text(k.meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 24,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (k.onyomi.isNotEmpty)
          Text('On: ${k.onyomi.join("、")}',
              style: AppTheme.jp(15).copyWith(color: AppColors.fg)),
        if (k.kunyomi.isNotEmpty)
          Text('Kun: ${k.kunyomi.join("、")}',
              style: AppTheme.jp(15).copyWith(color: AppColors.fg)),
      ],
    );
  }

  Widget _buildHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Tap card to flip • swipe ↑ know it • swipe ↓ still learning • $_known/$_seen known',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.fgMuted, fontSize: 11.5),
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
              'Flashcards',
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

  Widget _buildFilterChips() {
    const options = [
      ('mixed', 'Mixed'),
      ('vocab', 'Vocab'),
      ('kanji', 'Kanji'),
    ];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: options.map((o) {
          final selected = o.$1 == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(o.$2),
              selected: selected,
              onSelected: (_) => _setFilter(o.$1),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
