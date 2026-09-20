import 'package:flutter/material.dart';

/// Colors mirror the desktop Tkinter app's palette, so it feels like the
/// same app -- just native and touch-first now.
class AppColors {
  static const bg = Color(0xFF0F172A); // slate-900
  static const bgCard = Color(0xFF1E293B); // slate-800
  static const bgCardHover = Color(0xFF273449);
  static const fg = Color(0xFFE2E8F0); // slate-200
  static const fgMuted = Color(0xFF94A3B8); // slate-400
  static const accent = Color(0xFF38BDF8); // sky-400
  static const accentDark = Color(0xFF0284C7);
  static const good = Color(0xFF4ADE80); // green-400
  static const bad = Color(0xFFF87171); // red-400
  static const warn = Color(0xFFFACC15); // yellow-400
  static const cardBorder = Color(0xFF334155);

  static const Map<String, Color> diffColors = {
    'easy': good,
    'normal': warn,
    'hard': bad,
  };
}

/// Font family for Japanese text -- the bundled Noto Sans JP subset,
/// guaranteed to render crisply regardless of what's on the phone.
const String kJpFontFamily = 'NotoJP';

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.accent,
        secondary: AppColors.accent,
        surface: AppColors.bgCard,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.fg,
        displayColor: AppColors.fg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.fg,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: const Color(0xFF042F3D),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      cardColor: AppColors.bgCard,
      dividerColor: AppColors.cardBorder,
    );
  }

  static TextStyle jp(double size, {FontWeight weight = FontWeight.w500}) {
    return TextStyle(
      fontFamily: kJpFontFamily,
      fontSize: size,
      fontWeight: weight,
      color: AppColors.fg,
      height: 1.35,
    );
  }

  static Color forDifficulty(String difficulty) =>
      AppColors.diffColors[difficulty] ?? AppColors.fgMuted;
}
