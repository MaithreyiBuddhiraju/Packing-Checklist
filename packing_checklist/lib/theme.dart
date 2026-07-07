import 'package:flutter/material.dart';

/// Palette lifted from the original web app (packing-app/index.html).
abstract final class AppColors {
  static const cream = Color(0xFFF5F0E8);
  static const navyDark = Color(0xFF1B2B3B);
  static const navy = Color(0xFF2D4A6E);
  static const green = Color(0xFF6B9E7E);
  static const orange = Color(0xFFE8865A);
  static const blue = Color(0xFF5B8DB8);
  static const mutedText = Color(0xFF8A7E75);
  static const struckText = Color(0xFFB0A898);
  static const badgeDoneBg = Color(0xFFDCF2E4);
  static const badgeDoneFg = Color(0xFF2A7A48);
  static const badgeTodoBg = Color(0xFFEEE6DA);
  static const badgeTodoFg = Color(0xFF7A6558);

  static const _tagPalette = [
    blue,
    orange,
    green,
    Color(0xFF8E7CC3),
    Color(0xFFC27BA0),
    Color(0xFF6AA84F),
  ];

  /// SF/LA/Both keep their web-app colors; any other tag gets a stable
  /// color derived from its text.
  static Color tagColor(String tag) {
    switch (tag.trim().toLowerCase()) {
      case 'sf':
        return blue;
      case 'la':
        return orange;
      case 'both':
        return green;
    }
    final h = tag.trim().toLowerCase().hashCode & 0x7fffffff;
    return _tagPalette[h % _tagPalette.length];
  }
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.navy);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navyDark,
      foregroundColor: Colors.white,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.green : null),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 11),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: AppColors.green),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
