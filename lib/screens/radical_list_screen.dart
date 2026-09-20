import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/radical_entry.dart';
import '../services/data_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/difficulty_badge.dart';
import 'radical_detail_screen.dart';

class RadicalListScreen extends StatefulWidget {
  const RadicalListScreen({super.key});

  @override
  State<RadicalListScreen> createState() => _RadicalListScreenState();
}

class _RadicalListScreenState extends State<RadicalListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<AudioService>().stopMenuMusic();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RadicalEntry> get _filtered {
    final all = DataService.instance.radicals;
    if (_query.isEmpty) return all;
    return all.where((r) {
      return r.char.contains(_query) ||
          r.meaning.toLowerCase().contains(_query) ||
          r.name.toLowerCase().contains(_query);
    }).toList();
  }

  void _openDetail(RadicalEntry r) {
    context.read<AudioService>().playLessonClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RadicalDetailScreen(radical: r)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: _buildSearchField(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${results.length} radical${results.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: AppColors.fgMuted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No radicals match "$_query".',
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(color: AppColors.fgMuted),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: results.length,
                        itemBuilder: (context, index) =>
                            _radicalTile(results[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.fg),
        decoration: InputDecoration(
          hintText: 'Search by name or meaning…',
          hintStyle: const TextStyle(color: AppColors.fgMuted),
          prefixIcon: const Icon(Icons.search, color: AppColors.fgMuted),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.fgMuted),
                  onPressed: () => _searchController.clear(),
                ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _radicalTile(RadicalEntry r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.bgCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openDetail(r),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    r.char,
                    textAlign: TextAlign.center,
                    style: AppTheme.jp(28, weight: FontWeight.w700)
                        .copyWith(color: AppColors.accent),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.meaning,
                        style: const TextStyle(
                          color: AppColors.fg,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        r.name,
                        style: AppTheme.jp(12.5)
                            .copyWith(color: AppColors.fgMuted),
                      ),
                    ],
                  ),
                ),
                DifficultyBadge(difficulty: r.difficulty),
              ],
            ),
          ),
        ),
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
              'Radicals',
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
