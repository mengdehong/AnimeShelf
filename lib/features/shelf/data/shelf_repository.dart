import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/exceptions/database_exception.dart';
import 'package:anime_shelf/core/utils/rank_utils.dart';
import 'package:drift/drift.dart';

/// Data class grouping a tier with its entries and their primary subjects.
class TierWithEntries {
  final Tier tier;
  final List<EntryWithSubject> entries;

  const TierWithEntries({required this.tier, required this.entries});
}

/// Data class pairing an entry with its primary subject snapshot.
class EntryWithSubject {
  final Entry entry;
  final Subject? subject;

  const EntryWithSubject({required this.entry, this.subject});
}

/// Repository for shelf operations — CRUD on tiers, entries, and ranking.
class ShelfRepository {
  final AppDatabase _db;

  ShelfRepository(this._db);

  /// Watches all tiers ordered by [tierSort], each with its entries
  /// ordered by [entryRank].
  Stream<List<TierWithEntries>> watchTiersWithEntries() {
    final query =
        _db.select(_db.tiers).join([
          leftOuterJoin(
            _db.entries,
            _db.entries.tierId.equalsExp(_db.tiers.id),
          ),
          leftOuterJoin(
            _db.subjects,
            _db.subjects.subjectId.equalsExp(_db.entries.primarySubjectId),
          ),
        ])..orderBy([
          OrderingTerm.asc(_db.tiers.tierSort),
          OrderingTerm.asc(_db.entries.entryRank),
        ]);

    return query.watch().map((rows) {
      final tierMap = <int, TierWithEntries>{};
      final result = <TierWithEntries>[];

      for (final row in rows) {
        final tier = row.readTable(_db.tiers);
        final entry = row.readTableOrNull(_db.entries);
        final subject = row.readTableOrNull(_db.subjects);

        var tierWithEntries = tierMap[tier.id];
        if (tierWithEntries == null) {
          tierWithEntries = TierWithEntries(tier: tier, entries: []);
          tierMap[tier.id] = tierWithEntries;
          result.add(tierWithEntries);
        }

        if (entry != null) {
          tierWithEntries.entries.add(
            EntryWithSubject(entry: entry, subject: subject),
          );
        }
      }

      return result;
    });
  }

  /// Moves an entry to [targetTierId] with [newRank].
  Future<void> moveEntry({
    required int entryId,
    required int targetTierId,
    required double newRank,
  }) async {
    try {
      await (_db.update(_db.entries)..where((e) => e.id.equals(entryId))).write(
        EntriesCompanion(
          tierId: Value(targetTierId),
          entryRank: Value(newRank),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to move entry $entryId',
        originalError: e,
      );
    }
  }

  /// Reorders a tier to a new sort position.
  Future<void> reorderTier({
    required int tierId,
    required double newSort,
  }) async {
    try {
      await (_db.update(_db.tiers)..where((t) => t.id.equals(tierId))).write(
        TiersCompanion(tierSort: Value(newSort)),
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to reorder tier $tierId',
        originalError: e,
      );
    }
  }

  /// Re-compresses all entry ranks within a tier to evenly-spaced values.
  Future<void> recompressEntryRanks(int tierId) async {
    try {
      await _db.transaction(() async {
        final entries =
            await (_db.select(_db.entries)
                  ..where((e) => e.tierId.equals(tierId))
                  ..orderBy([(e) => OrderingTerm.asc(e.entryRank)]))
                .get();

        final newRanks = RankUtils.recompressRanks(entries.length);
        for (var i = 0; i < entries.length; i++) {
          await (_db.update(_db.entries)
                ..where((e) => e.id.equals(entries[i].id)))
              .write(EntriesCompanion(entryRank: Value(newRanks[i])));
        }
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to recompress ranks for tier $tierId',
        originalError: e,
      );
    }
  }

  /// Re-compresses all tier sort values to evenly-spaced values.
  Future<void> recompressTierSorts() async {
    try {
      await _db.transaction(() async {
        final allTiers = await (_db.select(
          _db.tiers,
        )..orderBy([(t) => OrderingTerm.asc(t.tierSort)])).get();

        final newSorts = RankUtils.recompressRanks(allTiers.length);
        for (var i = 0; i < allTiers.length; i++) {
          await (_db.update(_db.tiers)
                ..where((t) => t.id.equals(allTiers[i].id)))
              .write(TiersCompanion(tierSort: Value(newSorts[i])));
        }
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to recompress tier sorts',
        originalError: e,
      );
    }
  }

  /// Adds a new tier with the given properties.
  Future<Tier> addTier({
    required String name,
    String emoji = '',
    required int colorValue,
  }) async {
    try {
      // Place new tier at the end
      final lastTier =
          await (_db.select(_db.tiers)
                ..orderBy([(t) => OrderingTerm.desc(t.tierSort)])
                ..limit(1))
              .getSingleOrNull();

      final sort = RankUtils.insertRank(lastTier?.tierSort, null);

      final id = await _db
          .into(_db.tiers)
          .insert(
            TiersCompanion.insert(
              name: name,
              emoji: Value(emoji),
              colorValue: colorValue,
              tierSort: sort,
            ),
          );
      return await (_db.select(
        _db.tiers,
      )..where((t) => t.id.equals(id))).getSingle();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to add tier "$name"',
        originalError: e,
      );
    }
  }

  /// Updates tier properties.
  Future<void> updateTier({
    required int tierId,
    String? name,
    String? emoji,
    int? colorValue,
  }) async {
    try {
      await (_db.update(_db.tiers)..where((t) => t.id.equals(tierId))).write(
        TiersCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          emoji: emoji != null ? Value(emoji) : const Value.absent(),
          colorValue: colorValue != null
              ? Value(colorValue)
              : const Value.absent(),
        ),
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update tier $tierId',
        originalError: e,
      );
    }
  }

  /// Deletes a tier and moves its entries to the Inbox.
  Future<void> deleteTier(int tierId) async {
    try {
      await _db.transaction(() async {
        // Find inbox
        final inbox = await (_db.select(
          _db.tiers,
        )..where((t) => t.isInbox.equals(true))).getSingle();

        // Move entries to inbox
        await (_db.update(_db.entries)..where((e) => e.tierId.equals(tierId)))
            .write(EntriesCompanion(tierId: Value(inbox.id)));

        // Delete the tier
        await (_db.delete(_db.tiers)..where((t) => t.id.equals(tierId))).go();
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete tier $tierId',
        originalError: e,
      );
    }
  }

  /// Deletes an entry and its subject associations.
  Future<void> deleteEntry(int entryId) async {
    try {
      await _db.transaction(() async {
        await (_db.delete(
          _db.entrySubjects,
        )..where((es) => es.entryId.equals(entryId))).go();
        await (_db.delete(
          _db.entries,
        )..where((e) => e.id.equals(entryId))).go();
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to delete entry $entryId',
        originalError: e,
      );
    }
  }

  /// Creates a new entry for a subject in the given tier.
  Future<Entry> createEntry({
    required int subjectId,
    required int tierId,
  }) async {
    try {
      return await _db.transaction(() async {
        // Get rank for end of tier
        final lastEntry =
            await (_db.select(_db.entries)
                  ..where((e) => e.tierId.equals(tierId))
                  ..orderBy([(e) => OrderingTerm.desc(e.entryRank)])
                  ..limit(1))
                .getSingleOrNull();

        final rank = RankUtils.insertRank(lastEntry?.entryRank, null);

        final id = await _db
            .into(_db.entries)
            .insert(
              EntriesCompanion.insert(
                tierId: tierId,
                primarySubjectId: subjectId,
                entryRank: rank,
              ),
            );

        // Create junction record
        await _db
            .into(_db.entrySubjects)
            .insert(
              EntrySubjectsCompanion.insert(entryId: id, subjectId: subjectId),
            );

        return (_db.select(
          _db.entries,
        )..where((e) => e.id.equals(id))).getSingle();
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to create entry for subject $subjectId',
        originalError: e,
      );
    }
  }

  /// Updates the note on an entry.
  Future<void> updateNote({required int entryId, required String note}) async {
    try {
      await (_db.update(_db.entries)..where((e) => e.id.equals(entryId))).write(
        EntriesCompanion(note: Value(note), updatedAt: Value(DateTime.now())),
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to update note on entry $entryId',
        originalError: e,
      );
    }
  }

  /// Checks if a subject already exists as an entry on the shelf.
  Future<bool> subjectExists(int subjectId) async {
    final count = await (_db.select(
      _db.entrySubjects,
    )..where((es) => es.subjectId.equals(subjectId))).get();
    return count.isNotEmpty;
  }
}
