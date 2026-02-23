import 'package:anime_shelf/models/entry.dart';
import 'package:anime_shelf/models/entry_subject.dart';
import 'package:anime_shelf/models/subject.dart';
import 'package:anime_shelf/models/tier.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Central Drift database for AnimeShelf.
///
/// Contains all four tables and handles schema migrations
/// and initial seed data (default tiers + inbox).
@DriftDatabase(tables: [Tiers, Subjects, Entries, EntrySubjects])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'anime_shelf'));

  @override
  int get schemaVersion => 2;

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
      },
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

  /// Seeds the database with an Inbox tier and three default tiers.
  Future<void> _seedDefaultTiers() async {
    await batch((batch) {
      batch.insertAll(tiers, [
        TiersCompanion.insert(
          name: 'Inbox',
          colorValue: 0xFF9E9E9E,
          tierSort: 0.0,
          isInbox: const Value(true),
        ),
        TiersCompanion.insert(
          name: 'S',
          emoji: const Value('\u{1F451}'),
          colorValue: 0xFFFFD700,
          tierSort: 1000.0,
        ),
        TiersCompanion.insert(
          name: 'A',
          emoji: const Value('\u{2B50}'),
          colorValue: 0xFFFF6B6B,
          tierSort: 2000.0,
        ),
        TiersCompanion.insert(
          name: 'B',
          emoji: const Value('\u{1F44D}'),
          colorValue: 0xFF4ECDC4,
          tierSort: 3000.0,
        ),
      ]);
    });
  }
}
