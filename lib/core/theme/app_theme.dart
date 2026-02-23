import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class AppThemeMetrics extends ThemeExtension<AppThemeMetrics> {
  const AppThemeMetrics({
    required this.cardRadius,
    required this.controlRadius,
    required this.sectionRadius,
    required this.posterRadius,
    required this.tileRadius,
    required this.cardElevation,
    required this.cardShadowOpacity,
    required this.fabCircular,
    required this.appBarBackground,
    required this.inputFillColor,
  });

  final double cardRadius;
  final double controlRadius;
  final double sectionRadius;
  final double posterRadius;
  final double tileRadius;
  final double cardElevation;
  final double cardShadowOpacity;
  final bool fabCircular;
  final Color appBarBackground;
  final Color inputFillColor;

  @override
  AppThemeMetrics copyWith({
    double? cardRadius,
    double? controlRadius,
    double? sectionRadius,
    double? posterRadius,
    double? tileRadius,
    double? cardElevation,
    double? cardShadowOpacity,
    bool? fabCircular,
    Color? appBarBackground,
    Color? inputFillColor,
  }) {
    return AppThemeMetrics(
      cardRadius: cardRadius ?? this.cardRadius,
      controlRadius: controlRadius ?? this.controlRadius,
      sectionRadius: sectionRadius ?? this.sectionRadius,
      posterRadius: posterRadius ?? this.posterRadius,
      tileRadius: tileRadius ?? this.tileRadius,
      cardElevation: cardElevation ?? this.cardElevation,
      cardShadowOpacity: cardShadowOpacity ?? this.cardShadowOpacity,
      fabCircular: fabCircular ?? this.fabCircular,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      inputFillColor: inputFillColor ?? this.inputFillColor,
    );
  }

  @override
  AppThemeMetrics lerp(ThemeExtension<AppThemeMetrics>? other, double t) {
    if (other is! AppThemeMetrics) {
      return this;
    }

    return AppThemeMetrics(
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t) ?? cardRadius,
      controlRadius:
          lerpDouble(controlRadius, other.controlRadius, t) ?? controlRadius,
      sectionRadius:
          lerpDouble(sectionRadius, other.sectionRadius, t) ?? sectionRadius,
      posterRadius:
          lerpDouble(posterRadius, other.posterRadius, t) ?? posterRadius,
      tileRadius: lerpDouble(tileRadius, other.tileRadius, t) ?? tileRadius,
      cardElevation:
          lerpDouble(cardElevation, other.cardElevation, t) ?? cardElevation,
      cardShadowOpacity:
          lerpDouble(cardShadowOpacity, other.cardShadowOpacity, t) ??
          cardShadowOpacity,
      fabCircular: t < 0.5 ? fabCircular : other.fabCircular,
      appBarBackground:
          Color.lerp(appBarBackground, other.appBarBackground, t) ??
          appBarBackground,
      inputFillColor:
          Color.lerp(inputFillColor, other.inputFillColor, t) ?? inputFillColor,
    );
  }
}

class AppTheme {
  AppTheme._();

  static final List<ThemeData> _allThemes = List<ThemeData>.unmodifiable([
    sakuraPink(),
    bilibiliRed(),
    dark(),
  ]);

  static ThemeData sakuraPink() {
    const primary = Color(0xFFF09199);
    const surface = Color(0xFFF5F5F7);
    const card = Color(0xFFFFFFFF);
    const text = Color(0xFF222222);

    return _buildTheme(
      brightness: Brightness.light,
      primary: primary,
      surface: surface,
      card: card,
      text: text,
      metrics: const AppThemeMetrics(
        cardRadius: 20,
        controlRadius: 16,
        sectionRadius: 16,
        posterRadius: 12,
        tileRadius: 8,
        cardElevation: 1,
        cardShadowOpacity: 0.04,
        fabCircular: false,
        appBarBackground: surface,
        inputFillColor: card,
      ),
    );
  }

  static ThemeData bilibiliRed() {
    const primary = Color(0xFFFB7299);
    const surface = Color(0xFFF6F7F8);
    const card = Color(0xFFFFFFFF);
    const text = Color(0xFF18191C);
    const bilibiliBlue = Color(0xFF00AEEC);

    return _buildTheme(
      brightness: Brightness.light,
      primary: primary,
      surface: surface,
      card: card,
      text: text,
      secondary: bilibiliBlue,
      metrics: const AppThemeMetrics(
        cardRadius: 12,
        controlRadius: 12,
        sectionRadius: 12,
        posterRadius: 6,
        tileRadius: 6,
        cardElevation: 1,
        cardShadowOpacity: 0.03,
        fabCircular: true,
        appBarBackground: card,
        inputFillColor: Color(0xFFF1F2F3),
      ),
    );
  }

  static ThemeData dark() {
    const primary = Color(0xFFCBA6F7);
    const surface = Color(0xFF1E1E2E);
    const card = Color(0xFF313244);
    const text = Color(0xFFCDD6F4);

    return _buildTheme(
      brightness: Brightness.dark,
      primary: primary,
      surface: surface,
      card: card,
      text: text,
      metrics: const AppThemeMetrics(
        cardRadius: 16,
        controlRadius: 14,
        sectionRadius: 16,
        posterRadius: 8,
        tileRadius: 8,
        cardElevation: 2,
        cardShadowOpacity: 0.20,
        fabCircular: false,
        appBarBackground: surface,
        inputFillColor: card,
      ),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color surface,
    required Color card,
    required Color text,
    required AppThemeMetrics metrics,
    Color? secondary,
  }) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: surface,
    );
    final colorScheme = baseScheme.copyWith(
      primary: primary,
      secondary: secondary ?? baseScheme.secondary,
      surface: surface,
      onSurface: text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      extensions: <ThemeExtension<dynamic>>[metrics],
      cardTheme: CardThemeData(
        color: card,
        elevation: metrics.cardElevation,
        shadowColor: Colors.black.withValues(alpha: metrics.cardShadowOpacity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(metrics.cardRadius),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: metrics.appBarBackground,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        elevation: 3,
        shape: metrics.fabCircular
            ? const CircleBorder()
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(metrics.controlRadius),
              ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: metrics.inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(metrics.controlRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(metrics.cardRadius),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(metrics.tileRadius),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(metrics.tileRadius),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: brightness == Brightness.light
            ? Colors.black.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: text, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: text, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: text),
        bodyMedium: TextStyle(color: text.withValues(alpha: 0.8)),
        bodySmall: TextStyle(color: text.withValues(alpha: 0.55)),
        labelSmall: TextStyle(
          color: text.withValues(alpha: 0.5),
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static List<ThemeData> get allThemes => _allThemes;

  static ThemeData themeAt(int index) {
    if (index < 0 || index >= _allThemes.length) {
      return _allThemes.first;
    }
    return _allThemes[index];
  }

  static const List<String> themeNames = [
    'Sakura Pink',
    'Bilibili Red',
    'Dark',
  ];
}
