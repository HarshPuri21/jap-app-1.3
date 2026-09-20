import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _click(BuildContext context) =>
      context.read<AudioService>().playMenuClick();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final audio = context.watch<AudioService>();

    return Scaffold(
      body: AppBackground(
        // Wrapping the settings screen itself in AppBackground means every
        // change below is visible live, right behind these controls --
        // the same way WhatsApp lets you preview a chat wallpaper.
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    _sectionLabel('Background'),
                    const SizedBox(height: 12),
                    _defaultTile(context, settings),
                    const SizedBox(height: 10),
                    _colorGrid(context, settings),
                    const SizedBox(height: 10),
                    _photoTile(context, settings),
                    if (settings.backgroundType != BackgroundType.appDefault) ...[
                      const SizedBox(height: 24),
                      _sectionLabel(
                          'Dimness (keeps text readable) — ${(settings.overlayOpacity * 100).round()}%'),
                      Slider(
                        value: settings.overlayOpacity,
                        min: 0.0,
                        max: 0.9,
                        activeColor: AppColors.accent,
                        inactiveColor: AppColors.cardBorder,
                        onChanged: (v) =>
                            context.read<SettingsService>().setOverlayOpacity(v),
                      ),
                    ],
                    const SizedBox(height: 28),
                    _sectionLabel('Sound'),
                    const SizedBox(height: 12),
                    _musicToggleTile(context, audio),
                    if (audio.menuMusicEnabled) ...[
                      const SizedBox(height: 18),
                      _sectionLabel(
                          'Menu music volume — ${(audio.menuMusicVolume * 100).round()}%'),
                      Slider(
                        value: audio.menuMusicVolume,
                        min: 0.0,
                        max: 1.0,
                        activeColor: AppColors.accent,
                        inactiveColor: AppColors.cardBorder,
                        onChanged: (v) =>
                            context.read<AudioService>().setMenuMusicVolume(v),
                      ),
                    ],
                    const SizedBox(height: 28),
                    _sectionLabel('Your progress'),
                    const SizedBox(height: 12),
                    _statsCard(settings),
                  ],
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

  Widget _musicToggleTile(BuildContext context, AudioService audio) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Icon(
              audio.menuMusicEnabled
                  ? Icons.music_note_outlined
                  : Icons.music_off_outlined,
              color: AppColors.fgMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text('Menu music',
                style:
                    TextStyle(color: AppColors.fg, fontWeight: FontWeight.w600)),
          ),
          Switch(
            value: audio.menuMusicEnabled,
            activeColor: AppColors.accent,
            onChanged: (v) {
              _click(context);
              context.read<AudioService>().setMenuMusicEnabled(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _defaultTile(BuildContext context, SettingsService settings) {
    final selected = settings.backgroundType == BackgroundType.appDefault;
    return _tile(
      selected: selected,
      onTap: () {
        _click(context);
        context.read<SettingsService>().setBackgroundDefault();
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), AppColors.bg],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text('App default',
              style: TextStyle(color: AppColors.fg, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (selected)
            const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
        ],
      ),
    );
  }

  Widget _colorGrid(BuildContext context, SettingsService settings) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(kBackgroundColorPresets.length, (index) {
        final color = kBackgroundColorPresets[index];
        final selected = settings.backgroundType == BackgroundType.color &&
            settings.backgroundColorIndex == index;
        return GestureDetector(
          onTap: () {
            _click(context);
            context.read<SettingsService>().setBackgroundColorIndex(index);
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.accent : Colors.transparent,
                width: 3,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }),
    );
  }

  Widget _photoTile(BuildContext context, SettingsService settings) {
    final selected = settings.backgroundType == BackgroundType.photo;
    return _tile(
      selected: selected,
      onTap: () async {
        _click(context);
        final ok = await context.read<SettingsService>().pickBackgroundPhoto();
        if (!ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No photo selected')),
          );
        }
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.photo_outlined,
                color: AppColors.fgMuted, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text('Choose a photo from your gallery',
                style:
                    TextStyle(color: AppColors.fg, fontWeight: FontWeight.w600)),
          ),
          if (selected)
            const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
        ],
      ),
    );
  }

  Widget _tile({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: AppColors.bgCard.withOpacity(0.6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.cardBorder,
              width: 1.4,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _statsCard(SettingsService settings) {
    final answered = settings.statsAnsweredTotal;
    final correct = settings.statsCorrectTotal;
    final pct = answered == 0 ? 0 : (100 * correct / answered).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statColumn('$answered', 'Answered'),
          _statColumn('$correct', 'Correct'),
          _statColumn('$pct%', 'Accuracy'),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: AppColors.fgMuted, fontSize: 11)),
      ],
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
              _click(context);
              Navigator.of(context).pop();
            },
          ),
          const Expanded(
            child: Text(
              'Settings',
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
