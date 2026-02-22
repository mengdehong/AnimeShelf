import 'dart:convert';

import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/utils/export_service.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ShelfRepository shelfRepo;
  late ExportService exportService;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    shelfRepo = ShelfRepository(db);
    exportService = ExportService(db, shelfRepo);
    // Trigger migration/seed
    await db.select(db.tiers).get();
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper: insert a subject and create an entry in the S tier.
  Future<void> seedTestData() async {
    await db
        .into(db.subjects)
        .insert(
          SubjectsCompanion.insert(
            subjectId: const Value(42),
            nameCn: const Value('Steins;Gate'),
            nameJp: const Value('シュタインズ・ゲート'),
            airDate: const Value('2011-04-06'),
            eps: const Value(24),
            rating: const Value(9.1),
            summary: const Value('Time travel anime'),
          ),
        );

    final tiers = await db.select(db.tiers).get();
    final tierS = tiers.firstWhere((t) => t.name == 'S');
    await shelfRepo.createEntry(subjectId: 42, tierId: tierS.id);

    // Update note on the entry
    final entries = await db.select(db.entries).get();
    await shelfRepo.updateNote(entryId: entries.first.id, note: 'Masterpiece!');
  }

  group('exportJson', () {
    test('exports correct structure with version', () async {
      final data = await exportService.exportJson();
      expect(data['version'], equals(1));
      expect(data.containsKey('exportedAt'), isTrue);
      expect(data.containsKey('tiers'), isTrue);
      expect(data.containsKey('subjects'), isTrue);
      expect(data.containsKey('entries'), isTrue);
      expect(data.containsKey('entrySubjects'), isTrue);
    });

    test('exports seed tiers', () async {
      final data = await exportService.exportJson();
      final tiers = data['tiers'] as List;
      expect(tiers.length, equals(4));
    });

    test('exports entries with subjects', () async {
      await seedTestData();
      final data = await exportService.exportJson();
      final subjects = data['subjects'] as List;
      expect(subjects.length, equals(1));
      expect(
        (subjects[0] as Map<String, dynamic>)['nameCn'],
        equals('Steins;Gate'),
      );

      final entries = data['entries'] as List;
      expect(entries.length, equals(1));
      expect(
        (entries[0] as Map<String, dynamic>)['note'],
        equals('Masterpiece!'),
      );
    });
  });

  group('exportCsv', () {
    test('produces CSV header', () async {
      final csv = await exportService.exportCsv();
      expect(
        csv.startsWith('Tier,Title,Original Title,Air Date,Rating,Note'),
        isTrue,
      );
    });

    test('includes entry data rows', () async {
      await seedTestData();
      final csv = await exportService.exportCsv();
      final lines = csv.trim().split('\n');
      // Header + 1 data row
      expect(lines.length, equals(2));
      expect(lines[1], contains('S'));
      expect(lines[1], contains('Steins;Gate'));
    });

    test('escapes CSV special characters', () async {
      // Insert subject with comma in name
      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              subjectId: const Value(99),
              nameCn: const Value('Hello, World'),
            ),
          );
      final tiers = await db.select(db.tiers).get();
      final tierA = tiers.firstWhere((t) => t.name == 'A');
      await shelfRepo.createEntry(subjectId: 99, tierId: tierA.id);

      final csv = await exportService.exportCsv();
      // The name with comma should be quoted
      expect(csv, contains('"Hello, World"'));
    });
  });

  group('exportMarkdown', () {
    test('starts with heading', () async {
      final md = await exportService.exportMarkdown();
      expect(md, startsWith('# AnimeShelf Export'));
    });

    test('includes tier headings', () async {
      final md = await exportService.exportMarkdown();
      expect(md, contains('## '));
      expect(md, contains('Inbox'));
    });

    test('includes entries with rating', () async {
      await seedTestData();
      final md = await exportService.exportMarkdown();
      expect(md, contains('**Steins;Gate**'));
      expect(md, contains('2011'));
      expect(md, contains('9.1/10'));
    });

    test('includes notes as blockquotes', () async {
      await seedTestData();
      final md = await exportService.exportMarkdown();
      expect(md, contains('> Masterpiece!'));
    });
  });

  group('importJson', () {
    test('full round-trip: export then import', () async {
      await seedTestData();
      final exported = await exportService.exportJson();
      final jsonString = jsonEncode(exported);

      // Import into fresh state
      await exportService.importJson(jsonString);

      // Verify tiers
      final tiers = await db.select(db.tiers).get();
      expect(tiers.length, equals(4));

      // Verify subjects
      final subjects = await db.select(db.subjects).get();
      expect(subjects.length, equals(1));
      expect(subjects[0].nameCn, equals('Steins;Gate'));

      // Verify entries
      final entries = await db.select(db.entries).get();
      expect(entries.length, equals(1));

      // Verify junction
      final junctions = await db.select(db.entrySubjects).get();
      expect(junctions.length, equals(1));
    });

    test('import clears existing data before inserting', () async {
      await seedTestData();

      // Export data
      final exported = await exportService.exportJson();
      final jsonString = jsonEncode(exported);

      // Add extra data
      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              subjectId: const Value(999),
              nameCn: const Value('Extra'),
            ),
          );

      // Import — should clear extra data
      await exportService.importJson(jsonString);

      final subjects = await db.select(db.subjects).get();
      expect(subjects.length, equals(1));
      expect(subjects[0].subjectId, equals(42));
    });

    test('import handles empty data gracefully', () async {
      final emptyData = jsonEncode({
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'tiers': <dynamic>[],
        'subjects': <dynamic>[],
        'entries': <dynamic>[],
        'entrySubjects': <dynamic>[],
      });

      await exportService.importJson(emptyData);

      final tiers = await db.select(db.tiers).get();
      expect(tiers, isEmpty);
    });
  });

  group('_csvEscape', () {
    // Test via exportCsv behavior since _csvEscape is private
    test('values without special chars are unquoted', () async {
      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              subjectId: const Value(1),
              nameCn: const Value('SimpleTitle'),
            ),
          );
      final tiers = await db.select(db.tiers).get();
      await shelfRepo.createEntry(subjectId: 1, tierId: tiers.first.id);

      final csv = await exportService.exportCsv();
      final dataLine = csv.trim().split('\n').last;
      // SimpleTitle should not be quoted
      expect(dataLine, contains('SimpleTitle'));
      expect(dataLine, isNot(contains('"SimpleTitle"')));
    });
  });
}
