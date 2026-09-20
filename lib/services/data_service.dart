import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

import '../models/sentence.dart';
import '../models/kanji_question.dart';
import '../models/vocab_entry.dart';
import '../models/kanji_entry.dart';
import '../models/radical_entry.dart';
import '../models/radical_question.dart';

/// Loads the precomputed data files (bundled as Flutter assets, built from
/// the exact same tested Python pipeline as the desktop app) once at app
/// startup, and hands out shuffled/filtered views of them.
class DataService {
  static final DataService instance = DataService._internal();
  DataService._internal();

  List<Sentence> sentences = [];
  List<KanjiQuestion> kanjiQuestions = [];
  List<VocabEntry> vocab = [];
  List<KanjiEntry> kanjiEntries = [];
  List<RadicalEntry> radicals = [];
  List<RadicalQuestion> radicalQuestions = [];

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    final sentencesRaw =
        await rootBundle.loadString('assets/data/sentences.json');
    sentences = (jsonDecode(sentencesRaw) as List<dynamic>)
        .map((e) => Sentence.fromJson(e as Map<String, dynamic>))
        .toList();

    final kanjiQRaw =
        await rootBundle.loadString('assets/data/kanji_questions.json');
    kanjiQuestions = (jsonDecode(kanjiQRaw) as List<dynamic>)
        .map((e) => KanjiQuestion.fromJson(e as Map<String, dynamic>))
        .toList();

    final vocabRaw = await rootBundle.loadString('assets/data/vocab.json');
    vocab = (jsonDecode(vocabRaw) as List<dynamic>)
        .map((e) => VocabEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    final kanjiRaw = await rootBundle.loadString('assets/data/kanji.json');
    kanjiEntries = (jsonDecode(kanjiRaw) as List<dynamic>)
        .map((e) => KanjiEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    final radicalsRaw =
        await rootBundle.loadString('assets/data/radicals.json');
    radicals = (jsonDecode(radicalsRaw) as List<dynamic>)
        .map((e) => RadicalEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    final radicalQRaw =
        await rootBundle.loadString('assets/data/radical_questions.json');
    radicalQuestions = (jsonDecode(radicalQRaw) as List<dynamic>)
        .map((e) => RadicalQuestion.fromJson(e as Map<String, dynamic>))
        .toList();

    _loaded = true;
  }

  List<Sentence> sentencesByDifficulty(String difficulty) {
    if (difficulty == 'all') return sentences;
    return sentences.where((s) => s.difficulty == difficulty).toList();
  }

  List<KanjiQuestion> kanjiByDifficulty(String difficulty) {
    if (difficulty == 'all') return kanjiQuestions;
    return kanjiQuestions.where((k) => k.difficulty == difficulty).toList();
  }

  List<RadicalQuestion> radicalsByDifficulty(String difficulty) {
    if (difficulty == 'all') return radicalQuestions;
    return radicalQuestions.where((r) => r.difficulty == difficulty).toList();
  }

  /// Returns `count` shuffled sentences at the given difficulty (or all
  /// difficulties mixed if `difficulty == 'all'`). `count <= 0` returns the
  /// whole (shuffled) pool.
  List<Sentence> drawSentences(String difficulty, int count) {
    final pool = List<Sentence>.from(sentencesByDifficulty(difficulty));
    pool.shuffle(Random());
    if (count <= 0 || count >= pool.length) return pool;
    return pool.sublist(0, count);
  }

  List<KanjiQuestion> drawKanji(String difficulty, int count) {
    final pool = List<KanjiQuestion>.from(kanjiByDifficulty(difficulty));
    pool.shuffle(Random());
    if (count <= 0 || count >= pool.length) return pool;
    return pool.sublist(0, count);
  }

  List<RadicalQuestion> drawRadicals(String difficulty, int count) {
    final pool = List<RadicalQuestion>.from(radicalsByDifficulty(difficulty));
    pool.shuffle(Random());
    if (count <= 0 || count >= pool.length) return pool;
    return pool.sublist(0, count);
  }

  /// A mixed test pulls from sentences, kanji, and radical questions,
  /// tagging each item by its runtime type so the UI can render any of them.
  List<dynamic> drawMixed(String difficulty, int count) {
    final pool = <dynamic>[
      ...sentencesByDifficulty(difficulty),
      ...kanjiByDifficulty(difficulty),
      ...radicalsByDifficulty(difficulty),
    ];
    pool.shuffle(Random());
    if (count <= 0 || count >= pool.length) return pool;
    return pool.sublist(0, count);
  }
}
