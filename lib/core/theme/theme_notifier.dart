import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_notifier.g.dart';

/// Manages theme selection, persisted via SharedPreferences.
///
/// Theme indices: 0 = Sakura Pink, 1 = Bilibili Red, 2 = Dark.
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  static const _key = 'theme_index';

  @override
  int build() {
    _loadSaved();
    return 0;
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_key);
    if (saved != null && saved != state) {
      state = saved;
    }
  }

  Future<void> setTheme(int index) async {
    state = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, index);
  }
}
