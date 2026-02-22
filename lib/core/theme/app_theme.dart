import 'package:flutter/material.dart';

/// Soft UI design theme factory for AnimeShelf.
///
/// Provides three built-in themes: Sakura Pink, Bilibili Red,
/// and a dark mode with non-pure-black tones.
class AppTheme {
  AppTheme._();

  static const double _borderRadius = 16.0;
  static const double _cardRadius = 20.0;

  // ── Sakura Pink (default light theme) ──

  static ThemeData sakuraPink() {
    const primary = Color(0xFFE91E8C);
    const surface = Color(0xFFFFF5F9);
    const card = Color(0xFFFFFFFF);
    const text = Color(0xFF2D2D2D);

    return _buildTheme(
      brightness: Brightness.light,
      primary: primary,
      surface: surface,
      card: card,
      text: text,
      seedColor: primary,
    );
  }

  // ── Bilibili Red ──

  static ThemeData bilibiliRed() {
    const primary = Color(0xFFFB7299);
    const surface = Color(0xFFFFF8F0);
    const card = Color(0xFFFFFFFF);
    const text = Color(0xFF2D2D2D);

    return _buildTheme(
      brightness: Brightness.light,
      primary: primary,
      surface: surface,
      card: card,
      text: text,
      seedColor: primary,
    );
  }

  // ── Dark Mode ──

  static ThemeData dark() {
    const primary = Color(0xFFBB86FC);
    const surface = Color(0xFF1E1E2E);
    const card = Color(0xFF2A2A3C);
    const text = Color(0xFFE0E0E0);

    return _buildTheme(
      brightness: Brightness.dark,
      primary: primary,
      surface: surface,
      card: card,
      text: text,
      seedColor: primary,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color surface,
    required Color card,
    required Color text,
    required Color seedColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      primary: primary,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      cardTheme: CardThemeData(
        color: card,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_cardRadius),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: text, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: text, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: text),
        bodyMedium: TextStyle(color: text.withValues(alpha: 0.8)),
        bodySmall: TextStyle(color: text.withValues(alpha: 0.6)),
      ),
    );
  }

  /// Returns a list of all available themes.
  static List<ThemeData> get allThemes => [sakuraPink(), bilibiliRed(), dark()];

  /// Human-readable names for each theme index.
  static const List<String> themeNames = [
    'Sakura Pink',
    'Bilibili Red',
    'Dark',
  ];
}
