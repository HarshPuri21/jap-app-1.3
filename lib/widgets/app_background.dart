import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../theme/app_theme.dart';

/// Wraps a screen's content with the user's chosen background -- the
/// app's default dark gradient, a flat accent color, or a picked photo
/// dimmed with a dark scrim (exactly like a WhatsApp chat wallpaper) so
/// text stays legible on top of any image.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackgroundLayer(settings),
        if (settings.backgroundType != BackgroundType.appDefault)
          Container(
            color: Colors.black.withOpacity(settings.overlayOpacity),
          ),
        child,
      ],
    );
  }

  Widget _buildBackgroundLayer(SettingsService settings) {
    switch (settings.backgroundType) {
      case BackgroundType.photo:
        final path = settings.backgroundPhotoPath;
        if (path != null && File(path).existsSync()) {
          return Image.file(File(path), fit: BoxFit.cover);
        }
        return _defaultGradient();
      case BackgroundType.color:
        return Container(color: settings.backgroundColor);
      case BackgroundType.appDefault:
        return _defaultGradient();
    }
  }

  Widget _defaultGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), AppColors.bg],
        ),
      ),
    );
  }
}
