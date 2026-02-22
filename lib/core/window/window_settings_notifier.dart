import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

part 'window_settings_notifier.g.dart';

/// Whether the native OS title bar is hidden on Linux desktop.
/// Only meaningful when [Platform.isLinux] is true.
@Riverpod(keepAlive: true)
class WindowSettingsNotifier extends _$WindowSettingsNotifier {
  static const _keyHideTitleBar = 'window_title_bar_hidden';

  @override
  bool build() {
    _loadSaved();
    return false;
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_keyHideTitleBar);
    if (saved != null && saved != state) {
      state = saved;
    }
  }

  /// Toggles the title bar visibility and persists the preference.
  ///
  /// On Linux the change is applied immediately via [windowManager]; on some
  /// Wayland compositors an app restart may be needed for it to take effect.
  Future<void> setHideTitleBar(bool hide) async {
    state = hide;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHideTitleBar, hide);

    if (Platform.isLinux) {
      await windowManager.setTitleBarStyle(
        hide ? TitleBarStyle.hidden : TitleBarStyle.normal,
      );
    }
  }
}
