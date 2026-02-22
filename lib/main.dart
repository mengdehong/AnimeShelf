import 'package:anime_shelf/core/router.dart';
import 'package:anime_shelf/core/theme/app_theme.dart';
import 'package:anime_shelf/core/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AnimeShelfApp()));
}

/// Root application widget.
class AnimeShelfApp extends ConsumerWidget {
  const AnimeShelfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeIndex = ref.watch(themeNotifierProvider);
    final themes = AppTheme.allThemes;
    final theme = themeIndex >= 0 && themeIndex < themes.length
        ? themes[themeIndex]
        : themes[0];

    return MaterialApp.router(
      title: 'AnimeShelf',
      theme: theme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
