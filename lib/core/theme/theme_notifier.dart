import 'package:anime_shelf/core/theme/app_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_notifier.g.dart';

/// Manages theme selection, persisted via SharedPreferences.
///
/// Theme indices:
/// 0 = Bilibili Red,
/// 1 = Dark,
/// 2 = Pixiv Blue,
/// 3 = Miku Teal.
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  static const _key = 'theme_index';
  static const _schemaVersionKey = 'theme_schema_version';
  static const _currentSchemaVersion = 2;

  @override
  int build() {
    _loadSaved();
    return 0;
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final schemaVersion = prefs.getInt(_schemaVersionKey) ?? 1;
    final saved = prefs.getInt(_key);
    if (saved == null) {
      return;
    }

    final migrated = schemaVersion < _currentSchemaVersion
        ? _migrateLegacyThemeIndex(saved)
        : saved;
    final bounded = migrated.clamp(0, AppTheme.allThemes.length - 1).toInt();

    if (bounded != state) {
      state = bounded;
    }

    if (bounded != saved || schemaVersion != _currentSchemaVersion) {
      await prefs.setInt(_key, bounded);
      await prefs.setInt(_schemaVersionKey, _currentSchemaVersion);
    }
  }

  Future<void> setTheme(int index) async {
    state = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, index);
    await prefs.setInt(_schemaVersionKey, _currentSchemaVersion);
  }

  int _migrateLegacyThemeIndex(int index) {
    switch (index) {
      case 0:
      case 1:
        return 0;
      case 2:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return 0;
    }
  }
}
