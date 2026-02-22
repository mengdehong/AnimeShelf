import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/network/bangumi_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Global database provider — single instance for the app lifetime.
@Riverpod(keepAlive: true)
AppDatabase database(DatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

/// Global Bangumi API client provider.
@Riverpod(keepAlive: true)
BangumiClient bangumiClient(BangumiClientRef ref) {
  return BangumiClient();
}
