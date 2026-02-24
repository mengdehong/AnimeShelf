import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/exceptions/database_exception.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ShelfRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = ShelfRepository(db);
    // Wait for seed data to populate
    await db.select(db.tiers).get(); // triggers migration/seed on first access
  });

  tearDown(() async {
    await db.close();
  });

  group('Tier operations', () {
    test('seed creates 8 default tiers with Inbox at the bottom', () async {
      final tiers = await (db.select(
        db.tiers,
      )..orderBy([(t) => OrderingTerm.asc(t.tierSort)])).get();
      expect(tiers.length, equals(8));
      expect(tiers[0].name, equals('SSS'));
      expect(tiers[1].name, equals('SS'));
      expect(tiers[2].name, equals('S'));
      expect(tiers[3].name, equals('A'));
      expect(tiers[4].name, equals('B'));
      expect(tiers[5].name, equals('C'));
      expect(tiers[6].name, equals('D'));
      expect(tiers[7].name, equals('Inbox'));
      expect(tiers[7].isInbox, isTrue);
    });

    test('addTier places new tier after the last one', () async {
      final newTier = await repo.addTier(
        name: 'C',
        emoji: '',
        colorValue: 0xFF00FF00,
      );
      expect(newTier.name, equals('C'));
      expect(newTier.tierSort, greaterThan(8000.0));
    });

    test('updateTier changes name', () async {
      final tiers = await db.select(db.tiers).get();
      final tierS = tiers.firstWhere((t) => t.name == 'S');

      await repo.updateTier(tierId: tierS.id, name: 'S+');
      final updated = await (db.select(
        db.tiers,
      )..where((t) => t.id.equals(tierS.id))).getSingle();
      expect(updated.name, equals('S+'));
    });

    test('updateTier changes color without affecting name', () async {
      final tiers = await db.select(db.tiers).get();
      final tierA = tiers.firstWhere((t) => t.name == 'A');

      await repo.updateTier(tierId: tierA.id, colorValue: 0xFFFF0000);
      final updated = await (db.select(
        db.tiers,
      )..where((t) => t.id.equals(tierA.id))).getSingle();
      expect(updated.name, equals('A'));
      expect(updated.colorValue, equals(0xFFFF0000));
    });

    test('reorderTier changes tierSort', () async {
      final tiers = await (db.select(
        db.tiers,
      )..orderBy([(t) => OrderingTerm.asc(t.tierSort)])).get();
      final tierB = tiers.firstWhere((t) => t.name == 'B');

      await repo.reorderTier(tierId: tierB.id, newSort: 500.0);
      final updated = await (db.select(
        db.tiers,
      )..where((t) => t.id.equals(tierB.id))).getSingle();
      expect(updated.tierSort, equals(500.0));
    });

    test('setTierOrder applies provided order with fresh spacing', () async {
      final tiers = await (db.select(
        db.tiers,
      )..orderBy([(t) => OrderingTerm.asc(t.tierSort)])).get();
      final inbox = tiers.firstWhere((tier) => tier.isInbox);

      final ordered =
          tiers.where((tier) => !tier.isInbox).toList(growable: true)
            ..insert(0, inbox);
      await repo.setTierOrder(
        ordered.map((tier) => tier.id).toList(growable: false),
      );

      final reordered = await (db.select(
        db.tiers,
      )..orderBy([(t) => OrderingTerm.asc(t.tierSort)])).get();

      expect(reordered.first.id, equals(inbox.id));
      expect(reordered.first.tierSort, equals(1000.0));
      expect(reordered[1].tierSort, equals(2000.0));
      expect(reordered.last.tierSort, equals(8000.0));
    });

    test('saveTierManagementChanges creates pending tiers and order', () async {
      final tiers = await (db.select(
        db.tiers,
      )..orderBy([(t) => OrderingTerm.asc(t.tierSort)])).get();
      final inbox = tiers.firstWhere((tier) => tier.isInbox);
      final sss = tiers.firstWhere((tier) => tier.name == 'SSS');
      final remaining = tiers
          .where((tier) => tier.id != inbox.id && tier.id != sss.id)
          .toList(growable: false);

      final orderedItems = <TierManagementItem>[
        TierManagementItem.existing(tierId: inbox.id),
        const TierManagementItem.pending(
          pendingTier: PendingTierDraft(
            name: 'S+',
            emoji: '✨',
            colorValue: 0xFF123456,
          ),
        ),
        TierManagementItem.existing(tierId: sss.id),
        ...remaining.map(
          (tier) => TierManagementItem.existing(tierId: tier.id),
        ),
      ];

      await repo.saveTierManagementChanges(orderedItems);

      final reordered = await (db.select(
        db.tiers,
      )..orderBy([(t) => OrderingTerm.asc(t.tierSort)])).get();

      expect(reordered.length, equals(9));
      expect(reordered[0].id, equals(inbox.id));
      expect(reordered[1].name, equals('S+'));
      expect(reordered[1].emoji, equals('✨'));
      expect(reordered[1].tierSort, equals(2000.0));
      expect(reordered.last.tierSort, equals(9000.0));
    });

    test(
      'saveTierManagementChanges validates existing tier coverage',
      () async {
        final tiers = await db.select(db.tiers).get();
        final missingOne = tiers
            .skip(1)
            .map((tier) => TierManagementItem.existing(tierId: tier.id))
            .toList(growable: false);

        await expectLater(
          () => repo.saveTierManagementChanges(missingOne),
          throwsA(isA<DatabaseException>()),
        );

        final unchanged = await db.select(db.tiers).get();
        expect(unchanged.length, equals(8));
      },
    );

    test('recompressTierSorts evenly spaces tiers', () async {
      // Mess up tier sorts to be very close
      final tiers = await db.select(db.tiers).get();
      for (final tier in tiers) {
        await (db.update(db.tiers)..where((t) => t.id.equals(tier.id))).write(
          TiersCompanion(tierSort: Value(tier.tierSort * 0.001)),
        );
      }

      await repo.recompressTierSorts();

      final recompressed = await (db.select(
        db.tiers,
      )..orderBy([(t) => OrderingTerm.asc(t.tierSort)])).get();
      expect(recompressed[0].tierSort, equals(1000.0));
      expect(recompressed[1].tierSort, equals(2000.0));
      expect(recompressed[2].tierSort, equals(3000.0));
      expect(recompressed[3].tierSort, equals(4000.0));
      expect(recompressed[4].tierSort, equals(5000.0));
      expect(recompressed[5].tierSort, equals(6000.0));
      expect(recompressed[6].tierSort, equals(7000.0));
      expect(recompressed[7].tierSort, equals(8000.0));
    });

    test('deleteTier moves entries to inbox', () async {
      // Insert a subject first
      await db
          .into(db.subjects)
          .insert(SubjectsCompanion.insert(subjectId: const Value(42)));

      final tiers = await db.select(db.tiers).get();
      final tierS = tiers.firstWhere((t) => t.name == 'S');
      final inbox = tiers.firstWhere((t) => t.isInbox);

      // Create entry in tier S
      final entry = await repo.createEntry(subjectId: 42, tierId: tierS.id);
      expect(entry.tierId, equals(tierS.id));

      // Delete tier S
      await repo.deleteTier(tierS.id);

      // Entry should now be in inbox
      final movedEntry = await (db.select(
        db.entries,
      )..where((e) => e.id.equals(entry.id))).getSingle();
      expect(movedEntry.tierId, equals(inbox.id));

      // Tier S should be gone
      final remaining = await db.select(db.tiers).get();
      expect(remaining.any((t) => t.name == 'S'), isFalse);
    });
  });

  group('Entry operations', () {
    late int tierId;

    setUp(() async {
      // Insert test subjects
      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              subjectId: const Value(100),
              nameCn: const Value('Test Subject'),
            ),
          );
      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              subjectId: const Value(200),
              nameCn: const Value('Another Subject'),
            ),
          );

      final tiers = await db.select(db.tiers).get();
      tierId = tiers.firstWhere((t) => t.name == 'S').id;
    });

    test('createEntry inserts entry and junction record', () async {
      final entry = await repo.createEntry(subjectId: 100, tierId: tierId);
      expect(entry.tierId, equals(tierId));
      expect(entry.primarySubjectId, equals(100));
      expect(entry.entryRank, equals(1000.0));

      // Junction record should exist
      final junctions = await db.select(db.entrySubjects).get();
      expect(junctions.length, equals(1));
      expect(junctions[0].entryId, equals(entry.id));
      expect(junctions[0].subjectId, equals(100));
    });

    test('second entry gets rank after the first', () async {
      final entry1 = await repo.createEntry(subjectId: 100, tierId: tierId);
      final entry2 = await repo.createEntry(subjectId: 200, tierId: tierId);
      expect(entry2.entryRank, greaterThan(entry1.entryRank));
    });

    test('moveEntry changes tier and rank', () async {
      final tiers = await db.select(db.tiers).get();
      final tierA = tiers.firstWhere((t) => t.name == 'A');
      final entry = await repo.createEntry(subjectId: 100, tierId: tierId);

      await repo.moveEntry(
        entryId: entry.id,
        targetTierId: tierA.id,
        newRank: 500.0,
      );

      final updated = await (db.select(
        db.entries,
      )..where((e) => e.id.equals(entry.id))).getSingle();
      expect(updated.tierId, equals(tierA.id));
      expect(updated.entryRank, equals(500.0));
    });

    test('deleteEntry removes entry and junction records', () async {
      final entry = await repo.createEntry(subjectId: 100, tierId: tierId);

      await repo.deleteEntry(entry.id);

      final entries = await db.select(db.entries).get();
      expect(entries.where((e) => e.id == entry.id), isEmpty);

      final junctions = await db.select(db.entrySubjects).get();
      expect(junctions.where((j) => j.entryId == entry.id), isEmpty);
    });

    test('updateNote sets note text', () async {
      final entry = await repo.createEntry(subjectId: 100, tierId: tierId);
      expect(entry.note, isEmpty);

      await repo.updateNote(entryId: entry.id, note: 'Great anime!');

      final updated = await (db.select(
        db.entries,
      )..where((e) => e.id.equals(entry.id))).getSingle();
      expect(updated.note, equals('Great anime!'));
    });

    test('subjectExists returns true for existing entry', () async {
      await repo.createEntry(subjectId: 100, tierId: tierId);
      expect(await repo.subjectExists(100), isTrue);
    });

    test('subjectExists returns false for non-existing entry', () async {
      expect(await repo.subjectExists(999), isFalse);
    });

    test('recompressEntryRanks evenly spaces entries', () async {
      // Create 3 entries with close ranks
      final e1 = await repo.createEntry(subjectId: 100, tierId: tierId);
      await repo.moveEntry(
        entryId: e1.id,
        targetTierId: tierId,
        newRank: 0.001,
      );

      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              subjectId: const Value(300),
              nameCn: const Value('Third'),
            ),
          );
      final e2 = await repo.createEntry(subjectId: 200, tierId: tierId);
      await repo.moveEntry(
        entryId: e2.id,
        targetTierId: tierId,
        newRank: 0.002,
      );
      final e3 = await repo.createEntry(subjectId: 300, tierId: tierId);
      await repo.moveEntry(
        entryId: e3.id,
        targetTierId: tierId,
        newRank: 0.003,
      );

      await repo.recompressEntryRanks(tierId);

      final entries =
          await (db.select(db.entries)
                ..where((e) => e.tierId.equals(tierId))
                ..orderBy([(e) => OrderingTerm.asc(e.entryRank)]))
              .get();
      expect(entries.length, equals(3));
      expect(entries[0].entryRank, equals(1000.0));
      expect(entries[1].entryRank, equals(2000.0));
      expect(entries[2].entryRank, equals(3000.0));
    });
  });

  group('watchTiersWithEntries', () {
    test('emits tiers with entries ordered correctly', () async {
      // Insert subject
      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              subjectId: const Value(100),
              nameCn: const Value('Anime A'),
            ),
          );

      final tiers = await db.select(db.tiers).get();
      final tierS = tiers.firstWhere((t) => t.name == 'S');

      await repo.createEntry(subjectId: 100, tierId: tierS.id);

      final result = await repo.watchTiersWithEntries().first;
      expect(result.length, equals(8)); // 8 seed tiers

      final sTier = result.firstWhere((t) => t.tier.name == 'S');
      expect(sTier.entries.length, equals(1));
      expect(sTier.entries[0].subject?.nameCn, equals('Anime A'));
    });

    test(
      'deleteAllEntries removes all entries and junction records, keeps tiers',
      () async {
        final defaultTiers = await db.select(db.tiers).get();

        await db
            .into(db.subjects)
            .insert(SubjectsCompanion.insert(subjectId: const Value(100)));
        await db
            .into(db.subjects)
            .insert(SubjectsCompanion.insert(subjectId: const Value(101)));

        await repo.createEntry(subjectId: 100, tierId: defaultTiers.first.id);
        await repo.createEntry(subjectId: 101, tierId: defaultTiers.last.id);

        var entries = await db.select(db.entries).get();
        expect(entries.length, equals(2));

        await repo.deleteAllEntries();

        entries = await db.select(db.entries).get();
        final junctions = await db.select(db.entrySubjects).get();
        final tiers = await db.select(db.tiers).get();

        expect(entries, isEmpty);
        expect(junctions, isEmpty);
        expect(tiers.length, equals(8));
      },
    );

    test('tiers are ordered by tierSort', () async {
      final result = await repo.watchTiersWithEntries().first;
      for (var i = 1; i < result.length; i++) {
        expect(
          result[i].tier.tierSort,
          greaterThan(result[i - 1].tier.tierSort),
        );
      }
    });
  });

  group('watchTiers', () {
    test('emits tiers ordered by tierSort', () async {
      final result = await repo.watchTiers().first;

      expect(result.length, equals(8));
      for (var i = 1; i < result.length; i++) {
        expect(result[i].tierSort, greaterThan(result[i - 1].tierSort));
      }
    });
  });

  group('watchEntriesByTier', () {
    test('emits entries ordered by rank with primary subject', () async {
      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              subjectId: const Value(100),
              nameCn: const Value('Anime A'),
            ),
          );
      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              subjectId: const Value(200),
              nameCn: const Value('Anime B'),
            ),
          );

      final tiers = await db.select(db.tiers).get();
      final tierS = tiers.firstWhere((t) => t.name == 'S');

      final first = await repo.createEntry(subjectId: 100, tierId: tierS.id);
      final second = await repo.createEntry(subjectId: 200, tierId: tierS.id);
      await repo.moveEntry(
        entryId: second.id,
        targetTierId: tierS.id,
        newRank: first.entryRank - 1,
      );

      final result = await repo.watchEntriesByTier(tierS.id).first;

      expect(result.length, equals(2));
      expect(result[0].subject?.nameCn, equals('Anime B'));
      expect(result[1].subject?.nameCn, equals('Anime A'));
    });
  });
}
