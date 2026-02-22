import 'dart:async';

import 'package:anime_shelf/core/providers.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shelf_provider.g.dart';

/// Provides the shelf repository instance.
@Riverpod(keepAlive: true)
ShelfRepository shelfRepository(ShelfRepositoryRef ref) {
  return ShelfRepository(ref.watch(databaseProvider));
}

/// Watches all tiers with their entries for the shelf UI.
@riverpod
Stream<List<TierWithEntries>> shelfTiers(ShelfTiersRef ref) {
  final repo = ref.watch(shelfRepositoryProvider);
  return repo.watchTiersWithEntries();
}
