import 'package:anime_shelf/models/entry.dart';
import 'package:anime_shelf/models/entry_subject.dart';
import 'package:anime_shelf/models/subject.dart';
import 'package:anime_shelf/models/tier.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

const _defaultRankTierNames = <String>{'sss', 'ss', 's', 'a', 'b', 'c', 'd'};
const _defaultRankTierSortByName = <String, double>{
  'sss': 1000.0,
  'ss': 2000.0,
  's': 3000.0,
  'a': 4000.0,
  'b': 5000.0,
  'c': 6000.0,
  'd': 7000.0,
};
const _defaultInboxSort = 8000.0;

class _DefaultTierSeed {
  final String name;
  final String emoji;
  final int colorValue;
  final double tierSort;
  final bool isInbox;

  const _DefaultTierSeed({
    required this.name,
    required this.colorValue,
    required this.tierSort,
    this.emoji = '',
    this.isInbox = false,
  });
}

const _defaultTierSeeds = <_DefaultTierSeed>[
  _DefaultTierSeed(
    name: 'Inbox',
    colorValue: 0xFF9E9E9E,
    tierSort: _defaultInboxSort,
    isInbox: true,
  ),
  _DefaultTierSeed(
    name: 'SSS',
    emoji: '\u{1F451}',
    colorValue: 0xFFFFD700,
    tierSort: 1000.0,
  ),
  _DefaultTierSeed(
    name: 'SS',
    emoji: '\u{2B50}',
    colorValue: 0xFFFFA726,
    tierSort: 2000.0,
  ),
  _DefaultTierSeed(
    name: 'S',
    emoji: '\u{1F525}',
    colorValue: 0xFFFF6B6B,
    tierSort: 3000.0,
  ),
  _DefaultTierSeed(
    name: 'A',
    emoji: '\u{1F44D}',
    colorValue: 0xFF4ECDC4,
    tierSort: 4000.0,
  ),
  _DefaultTierSeed(
    name: 'B',
    emoji: '\u{1F3AF}',
    colorValue: 0xFF45B7D1,
    tierSort: 5000.0,
  ),
  _DefaultTierSeed(
    name: 'C',
    emoji: '\u{1F642}',
    colorValue: 0xFF98D8C8,
    tierSort: 6000.0,
  ),
  _DefaultTierSeed(
    name: 'D',
    emoji: '\u{1FAE0}',
    colorValue: 0xFFB0BEC5,
    tierSort: 7000.0,
  ),
];

/// Central Drift database for AnimeShelf.
///
/// Contains all four tables and handles schema migrations
/// and initial seed data (default tiers + inbox).
@DriftDatabase(tables: [Tiers, Subjects, Entries, EntrySubjects])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'anime_shelf'));

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedDefaultTiers();
        await _createPerformanceIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await _createPerformanceIndexes();
        }
        if (from < 3) {
          await _forceResetDefaultTiersForV3();
        }
        if (from < 4) {
          await _addLocalImageColumns();
        }
        if (from < 5) {
          await _addMetadataColumns();
        }
        if (from < 6) {
          await _moveInboxToBottom();
        }
        if (from < 7) {
          await _normalizeDefaultTierOrderForV7();
        }
      },
    );
  }

  /// v7 migration: normalize default tier order to
  /// SSS > SS > S > A > B > C > D > Inbox.
  Future<void> _normalizeDefaultTierOrderForV7() async {
    final currentTiers = await select(tiers).get();

    await batch((batch) {
      for (final tier in currentTiers) {
        final targetSort = tier.isInbox
            ? _defaultInboxSort
            : _defaultRankTierSortByName[tier.name.trim().toLowerCase()];

        if (targetSort == null || tier.tierSort == targetSort) {
          continue;
        }

        batch.update(
          tiers,
          TiersCompanion(tierSort: Value(targetSort)),
          where: (tbl) => tbl.id.equals(tier.id),
        );
      }
    });
  }

  /// v6 migration: move Inbox tier below ranked tiers by default.
  Future<void> _moveInboxToBottom() async {
    final highestRankedTier =
        await (select(tiers)
              ..where((tier) => tier.isInbox.equals(false))
              ..orderBy([(tier) => OrderingTerm.desc(tier.tierSort)])
              ..limit(1))
            .getSingleOrNull();

    final targetSort = (highestRankedTier?.tierSort ?? 7000.0) + 1000.0;

    await (update(tiers)..where((tier) => tier.isInbox.equals(true))).write(
      TiersCompanion(tierSort: Value(targetSort)),
    );
  }

  /// v4 migration: add columns for local image storage.
  Future<void> _addLocalImageColumns() async {
    await customStatement(
      'ALTER TABLE subjects ADD COLUMN large_poster_url TEXT '
      "NOT NULL DEFAULT '';",
    );
    await customStatement(
      'ALTER TABLE subjects ADD COLUMN local_thumbnail_path TEXT '
      "NOT NULL DEFAULT '';",
    );
    await customStatement(
      'ALTER TABLE subjects ADD COLUMN local_large_image_path TEXT '
      "NOT NULL DEFAULT '';",
    );
  }

  /// v5 migration: add metadata columns for tags, staff, and global rank.
  Future<void> _addMetadataColumns() async {
    await customStatement(
      'ALTER TABLE subjects ADD COLUMN tags TEXT '
      "NOT NULL DEFAULT '';",
    );
    await customStatement(
      'ALTER TABLE subjects ADD COLUMN director TEXT '
      "NOT NULL DEFAULT '';",
    );
    await customStatement(
      'ALTER TABLE subjects ADD COLUMN studio TEXT '
      "NOT NULL DEFAULT '';",
    );
    await customStatement(
      'ALTER TABLE subjects ADD COLUMN global_rank INTEGER '
      'NOT NULL DEFAULT 0;',
    );
  }

  Future<void> _createPerformanceIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tiers_tier_sort '
      'ON tiers (tier_sort);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_entries_tier_rank '
      'ON entries (tier_id, entry_rank);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_entries_primary_subject '
      'ON entries (primary_subject_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_entry_subjects_subject_id '
      'ON entry_subjects (subject_id);',
    );
  }

  /// Seeds the database with Inbox + default ranking tiers.
  Future<void> _seedDefaultTiers() async {
    await batch((batch) {
      batch.insertAll(
        tiers,
        _defaultTierSeeds
            .map((seed) => _seedToCompanion(seed))
            .toList(growable: false),
      );
    });
  }

  /// v3 migration: force-resets tiers to Inbox + SSS/SS/S/A/B/C/D.
  ///
  /// Entries are preserved. Entries from legacy tiers whose names match
  /// the new defaults are mapped back to the matching tier; all other
  /// entries stay in Inbox.
  Future<void> _forceResetDefaultTiersForV3() async {
    final existingTiers = await select(tiers).get();

    Tier? inboxTier;
    final tierNameById = <int, String>{};

    for (final tier in existingTiers) {
      if (inboxTier == null && tier.isInbox) {
        inboxTier = tier;
      }
      tierNameById[tier.id] = tier.name.trim().toLowerCase();
    }

    if (inboxTier == null) {
      final inboxSeed = _defaultTierSeeds.first;
      final inboxId = await into(tiers).insert(_seedToCompanion(inboxSeed));
      inboxTier = await (select(
        tiers,
      )..where((tier) => tier.id.equals(inboxId))).getSingle();
      tierNameById[inboxTier.id] = inboxTier.name.trim().toLowerCase();
    }

    final resolvedInboxTier = inboxTier;

    final allEntries = await select(entries).get();
    final entryTargetNameById = <int, String>{};

    for (final entry in allEntries) {
      final sourceTierName = tierNameById[entry.tierId];
      if (sourceTierName != null &&
          _defaultRankTierNames.contains(sourceTierName)) {
        entryTargetNameById[entry.id] = sourceTierName;
      }
    }

    await update(tiers).replace(
      resolvedInboxTier.copyWith(
        name: 'Inbox',
        emoji: '',
        colorValue: 0xFF9E9E9E,
        tierSort: _defaultInboxSort,
        isInbox: true,
      ),
    );

    if (allEntries.isNotEmpty) {
      await update(
        entries,
      ).write(EntriesCompanion(tierId: Value(resolvedInboxTier.id)));
    }

    await (delete(
      tiers,
    )..where((tier) => tier.id.isNotValue(resolvedInboxTier.id))).go();

    await batch((batch) {
      for (final seed in _defaultTierSeeds.where((seed) => !seed.isInbox)) {
        batch.insert(tiers, _seedToCompanion(seed));
      }
    });

    if (entryTargetNameById.isEmpty) {
      return;
    }

    final currentTiers = await select(tiers).get();
    final tierIdByName = <String, int>{};

    for (final tier in currentTiers) {
      if (!tier.isInbox) {
        tierIdByName[tier.name.trim().toLowerCase()] = tier.id;
      }
    }

    await batch((batch) {
      entryTargetNameById.forEach((entryId, targetTierName) {
        final targetTierId = tierIdByName[targetTierName];
        if (targetTierId != null) {
          batch.update(
            entries,
            EntriesCompanion(tierId: Value(targetTierId)),
            where: (entry) => entry.id.equals(entryId),
          );
        }
      });
    });
  }

  TiersCompanion _seedToCompanion(_DefaultTierSeed seed) {
    return TiersCompanion.insert(
      name: seed.name,
      emoji: Value(seed.emoji),
      colorValue: seed.colorValue,
      tierSort: seed.tierSort,
      isInbox: Value(seed.isInbox),
    );
  }
}
