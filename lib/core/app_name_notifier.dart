import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_name_notifier.g.dart';

/// Manages the user-facing display name of the application.
///
/// Persisted via [SharedPreferences].  Defaults to `'AnimeShelf'`.
/// The name is shown in the [FusedAppBar] leading area on desktop and
/// can be edited from the Settings → Window section.
@Riverpod(keepAlive: true)
class AppNameNotifier extends _$AppNameNotifier {
  static const _key = 'app_display_name';
  static const defaultName = 'AnimeShelf';

  @override
  String build() {
    _loadSaved();
    return defaultName;
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null && saved.isNotEmpty && saved != state) {
      state = saved;
    }
  }

  /// Persists [name] and updates the state immediately.
  ///
  /// If [name] is blank, the default name is restored instead.
  Future<void> setName(String name) async {
    final effective = name.trim().isEmpty ? defaultName : name.trim();
    state = effective;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, effective);
  }
}
