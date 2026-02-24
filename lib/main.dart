import 'dart:io';

import 'package:anime_shelf/core/router.dart';
import 'package:anime_shelf/core/theme/app_theme.dart';
import 'package:anime_shelf/core/theme/theme_notifier.dart';
import 'package:anime_shelf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux) {
    await windowManager.ensureInitialized();

    // Apply the persisted title-bar preference before the window is shown, so
    // there is no visible flicker between the native bar and the custom bar.
    final prefs = await SharedPreferences.getInstance();
    final hideTitleBar = prefs.getBool('window_title_bar_hidden') ?? false;
    await windowManager.setTitleBarStyle(
      hideTitleBar ? TitleBarStyle.hidden : TitleBarStyle.normal,
    );
  }

  runApp(const ProviderScope(child: AnimeShelfApp()));
}

/// Root application widget.
class AnimeShelfApp extends ConsumerWidget {
  const AnimeShelfApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeIndex = ref.watch(themeNotifierProvider);
    final theme = AppTheme.themeAt(themeIndex);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: theme,
      themeAnimationDuration: const Duration(milliseconds: 120),
      themeAnimationCurve: Curves.linear,
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('zh'),
      debugShowCheckedModeBanner: false,
    );
  }
}
