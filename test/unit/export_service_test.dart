import 'dart:convert';

import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/exceptions/api_exception.dart';
import 'package:anime_shelf/core/network/bangumi_client.dart';
import 'package:anime_shelf/core/utils/export_service.dart';
import 'package:anime_shelf/features/search/data/search_repository.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBangumiClient extends Mock implements BangumiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late AppDatabase db;
  late ShelfRepository shelfRepo;
  late SearchRepository searchRepo;
  late ExportService exportService;
  late MockBangumiClient mockClient;
  late MockDio mockDio;
  late Map<String, List<Map<String, dynamic>>> searchFixtures;
  late Set<String> failingKeywords;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    shelfRepo = ShelfRepository(db);
    mockClient = MockBangumiClient();
    mockDio = MockDio();
    searchFixtures = <String, List<Map<String, dynamic>>>{};
    failingKeywords = <String>{};

    when(() => mockClient.dio).thenReturn(mockDio);
    when(
      () => mockDio.post<Map<String, dynamic>>(
        '/v0/search/subjects',
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((invocation) async {
      final data = invocation.namedArguments[#data] as Map<String, dynamic>;
      final keyword = data['keyword'] as String;
      if (failingKeywords.contains(keyword)) {
        throw const ApiException(message: 'mock search failed');
      }

      final results = searchFixtures[keyword] ?? <Map<String, dynamic>>[];

      return Response<Map<String, dynamic>>(
        data: {'total': results.length, 'data': results},
        requestOptions: RequestOptions(path: '/v0/search/subjects'),
        statusCode: 200,
      );
    });

    searchRepo = SearchRepository(mockClient, db);
    exportService = ExportService(db, shelfRepo, searchRepo: searchRepo);
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
      expect(tiers.length, equals(8));
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

  group('exportPlainText', () {
    test('returns empty text when shelf has no entries', () async {
      final text = await exportService.exportPlainText();
      expect(text, isEmpty);
    });

    test('includes tier header and entry title lines', () async {
      await seedTestData();
      final text = await exportService.exportPlainText();
      final lines = text.trim().split('\n');

      expect(lines.first, equals('S'));
      expect(lines, contains('Steins;Gate'));
    });

    test('falls back to original title when CN title is empty', () async {
      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              subjectId: const Value(555),
              nameCn: const Value(''),
              nameJp: const Value('シュタインズ・ゲート'),
            ),
          );

      final tiers = await db.select(db.tiers).get();
      final tierA = tiers.firstWhere((tier) => tier.name == 'A');
      await shelfRepo.createEntry(subjectId: 555, tierId: tierA.id);

      final text = await exportService.exportPlainText();
      expect(text, contains('A\n'));
      expect(text, contains('シュタインズ・ゲート'));
    });

    test('does not include markdown syntax or note lines', () async {
      await seedTestData();
      final text = await exportService.exportPlainText();

      expect(text, isNot(contains('# ')));
      expect(text, isNot(contains('**')));
      expect(text, isNot(contains('> ')));
      expect(text, isNot(contains('Masterpiece!')));
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
      expect(tiers.length, equals(8));

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

  group('importPlainText', () {
    test('supports tier header line and imports to target tier', () async {
      searchFixtures['clannad'] = [
        {
          'id': 101,
          'name': 'CLANNAD',
          'name_cn': 'Clannad',
          'summary': '',
          'air_date': '2007-10-04',
          'eps': 23,
        },
      ];
      searchFixtures['三月的狮子'] = [
        {
          'id': 102,
          'name': '3月のライオン',
          'name_cn': '三月的狮子',
          'summary': '',
          'air_date': '2016-10-08',
          'eps': 22,
        },
      ];

      const text = 'S\nclannad\n\n三月的狮子\n';
      final report = await exportService.importPlainText(text);

      final tiers = await db.select(db.tiers).get();
      final tierS = tiers.firstWhere((tier) => tier.name == 'S');
      final entries = await (db.select(
        db.entries,
      )..where((entry) => entry.tierId.equals(tierS.id))).get();

      expect(entries.length, equals(2));
      expect(report.importedCount, equals(2));
      expect(report.tierHeadersDetected, equals(1));
    });

    test('unknown tier header routes subsequent imports to inbox', () async {
      searchFixtures['clannad'] = [
        {
          'id': 201,
          'name': 'CLANNAD',
          'name_cn': 'Clannad',
          'summary': '',
          'air_date': '2007-10-04',
          'eps': 23,
        },
      ];

      const text = 'SSSS\nclannad\n';
      final report = await exportService.importPlainText(text);

      final tiers = await db.select(db.tiers).get();
      final inbox = tiers.firstWhere((tier) => tier.isInbox);
      final entries = await (db.select(
        db.entries,
      )..where((entry) => entry.tierId.equals(inbox.id))).get();

      expect(entries.length, equals(1));
      expect(report.unknownTierHeaders, contains('SSSS'));
      expect(report.inboxFallbackEntries.length, equals(1));
    });

    test('imports alias title when top result is strong', () async {
      searchFixtures['未闻花名'] = [
        {
          'id': 211,
          'name': 'あの日見た花の名前を僕達はまだ知らない。',
          'name_cn': '我们仍未知道那天所看见的花的名字。',
          'summary': '',
          'air_date': '2011-04-14',
          'eps': 11,
          'rating': {'score': 8.1, 'total': 21000},
        },
      ];

      final report = await exportService.importPlainText('未闻花名\n');

      final entries = await db.select(db.entries).get();
      expect(entries.length, equals(1));
      expect(report.importedCount, equals(1));
      expect(report.lowConfidenceSkipped, equals(0));
    });

    test('imports when query is contained in long official title', () async {
      searchFixtures['朝花夕誓'] = [
        {
          'id': 212,
          'name': 'さよならの朝に約束の花をかざろう',
          'name_cn': '朝花夕誓——于离别之朝束起约定之花',
          'summary': '',
          'air_date': '2018-02-24',
          'eps': 1,
          'rating': {'score': 7.9, 'total': 9000},
        },
      ];

      final report = await exportService.importPlainText('朝花夕誓\n');

      final entries = await db.select(db.entries).get();
      expect(entries.length, equals(1));
      expect(report.importedCount, equals(1));
      expect(report.lowConfidenceSkipped, equals(0));
    });

    test(
      'prefers canonical high-vote result over low-vote derivative',
      () async {
        searchFixtures['无职转生'] = [
          {
            'id': 213,
            'name': '【无职转生同人动画】血契之约',
            'name_cn': '【无职转生同人动画】血契之约',
            'summary': '',
            'air_date': '2025-01-01',
            'eps': 1,
            'rating': {'score': 4.3, 'total': 148},
          },
          {
            'id': 214,
            'name': '無職転生 ～異世界行ったら本気だす～',
            'name_cn': '无职转生～到了异世界就拿出真本事～',
            'summary': '',
            'air_date': '2021-01-10',
            'eps': 11,
            'rating': {'score': 7.9, 'total': 24485},
          },
        ];

        final report = await exportService.importPlainText('无职转生\n');

        final entries = await db.select(db.entries).get();
        expect(entries.length, equals(1));
        expect(report.importedCount, equals(1));
        expect(report.lowConfidenceSkipped, equals(0));
        expect(report.lineResults.single.matchedSubjectId, equals(214));
      },
    );

    test('keeps short ambiguous alias as low confidence', () async {
      searchFixtures['超炮'] = [
        {
          'id': 215,
          'name': '超魔神英雄伝ワタル',
          'name_cn': '超魔神英雄传',
          'summary': '',
          'air_date': '1997-10-02',
          'eps': 51,
          'rating': {'score': 7.2, 'total': 1130},
        },
        {
          'id': 216,
          'name': '超時空要塞マクロス',
          'name_cn': '超时空要塞',
          'summary': '',
          'air_date': '1982-10-03',
          'eps': 36,
          'rating': {'score': 7.8, 'total': 1664},
        },
      ];

      final report = await exportService.importPlainText('超炮\n');

      final entries = await db.select(db.entries).get();
      expect(entries, isEmpty);
      expect(report.importedCount, equals(0));
      expect(report.lowConfidenceSkipped, equals(1));
      expect(report.lowConfidenceEntries.single, contains('low confidence'));
    });

    test('does not treat numeric title as season mismatch', () async {
      searchFixtures['白色相簿2'] = [
        {
          'id': 301,
          'name': 'WHITE ALBUM2',
          'name_cn': '白色相簿2',
          'summary': '',
          'air_date': '2013-10-05',
          'eps': 13,
          'rating': {'score': 7.8, 'total': 9300},
        },
      ];

      final report = await exportService.importPlainText('白色相簿2\n');

      final entries = await db.select(db.entries).get();
      expect(entries.length, equals(1));
      expect(report.importedCount, equals(1));
      expect(report.lowConfidenceSkipped, equals(0));
    });

    test('ignores large suffix number in compact query', () async {
      searchFixtures['一拳超人12'] = [
        {
          'id': 302,
          'name': 'ワンパンマン',
          'name_cn': '一拳超人',
          'summary': '',
          'air_date': '2015-10-05',
          'eps': 12,
          'rating': {'score': 8.0, 'total': 20733},
        },
        {
          'id': 303,
          'name': 'ワンパンマン 第2期',
          'name_cn': '一拳超人 第二季',
          'summary': '',
          'air_date': '2019-04-09',
          'eps': 12,
          'rating': {'score': 6.5, 'total': 8579},
        },
      ];

      final report = await exportService.importPlainText('一拳超人12\n');

      final entries = await db.select(db.entries).get();
      expect(entries.length, equals(1));
      expect(report.importedCount, equals(1));
      expect(report.lineResults.single.matchedSubjectId, equals(302));
      expect(report.lowConfidenceSkipped, equals(0));
    });

    test('imports romanized alias for kud wafter', () async {
      searchFixtures['Kud wafter'] = [
        {
          'id': 304,
          'name': 'クドわふたー',
          'name_cn': '剧场版 库特wafter',
          'summary': '',
          'air_date': '2021-11-19',
          'eps': 1,
          'rating': {'score': 7.0, 'total': 1174},
        },
      ];

      final report = await exportService.importPlainText('Kud wafter\n');

      final entries = await db.select(db.entries).get();
      expect(entries.length, equals(1));
      expect(report.importedCount, equals(1));
      expect(report.lowConfidenceSkipped, equals(0));
      expect(report.lineResults.single.matchedSubjectId, equals(304));
    });

    test('skips low-confidence top1 matches', () async {
      searchFixtures['abc'] = [
        {
          'id': 301,
          'name': '完全不匹配标题',
          'name_cn': '完全不匹配标题',
          'summary': '',
          'air_date': '2010-01-01',
          'eps': 1,
          'rating': {'score': 0.0, 'total': 0},
        },
      ];

      const text = 'abc\n';
      final report = await exportService.importPlainText(text);

      final entries = await db.select(db.entries).get();
      expect(entries, isEmpty);
      expect(report.lowConfidenceSkipped, equals(1));
      expect(report.importedCount, equals(0));
    });

    test('skips season mismatch to avoid wrong season import', () async {
      searchFixtures['刀剑神域4'] = [
        {
          'id': 311,
          'name': 'ソードアート・オンライン',
          'name_cn': '刀剑神域',
          'summary': '',
          'air_date': '2012-07-07',
          'eps': 25,
          'rating': {'score': 8.0, 'total': 10000},
        },
        {
          'id': 312,
          'name': 'ソードアート・オンラインII',
          'name_cn': '刀剑神域 第二季',
          'summary': '',
          'air_date': '2014-07-05',
          'eps': 24,
          'rating': {'score': 7.5, 'total': 8000},
        },
      ];

      final report = await exportService.importPlainText('刀剑神域4\n');

      final entries = await db.select(db.entries).get();
      expect(entries, isEmpty);
      expect(report.lowConfidenceSkipped, equals(1));
      expect(report.importedCount, equals(0));
      expect(
        report.lowConfidenceEntries.single,
        contains('season indicator mismatch'),
      );
    });

    test('supports cancellation and reports remaining lines', () async {
      final token = PlainTextImportCancellationToken()..cancel();
      final report = await exportService.importPlainText(
        'clannad\n三月的狮子\n',
        cancellationToken: token,
      );

      expect(report.cancelled, isTrue);
      expect(report.importedCount, equals(0));
      expect(report.cancelledEntries.length, equals(2));
      expect(report.processedEntries, equals(0));
    });

    test('skips duplicate subjects in the same import batch', () async {
      searchFixtures['clannad'] = [
        {
          'id': 401,
          'name': 'CLANNAD',
          'name_cn': 'Clannad',
          'summary': '',
          'air_date': '2007-10-04',
          'eps': 23,
        },
      ];

      const text = 'S\nclannad\nclannad\n';
      final report = await exportService.importPlainText(text);

      final entries = await db.select(db.entries).get();
      expect(entries.length, equals(1));
      expect(report.importedCount, equals(1));
      expect(report.duplicateSkipped, equals(1));
    });

    test('continues importing when one search request fails', () async {
      searchFixtures['clannad'] = [
        {
          'id': 501,
          'name': 'CLANNAD',
          'name_cn': 'Clannad',
          'summary': '',
          'air_date': '2007-10-04',
          'eps': 23,
        },
      ];
      searchFixtures['未闻花名'] = [
        {
          'id': 502,
          'name': 'あの日見た花の名前を僕達はまだ知らない。',
          'name_cn': '我们仍未知道那天所看见的花的名字。',
          'summary': '',
          'air_date': '2011-04-14',
          'eps': 11,
          'rating': {'score': 8.1, 'total': 21000},
        },
      ];
      failingKeywords.add('花开伊吕波');

      final report = await exportService.importPlainText(
        'clannad\n花开伊吕波\n未闻花名\n',
      );

      final entries = await db.select(db.entries).get();
      expect(entries.length, equals(2));
      expect(report.importedCount, equals(2));
      expect(report.noResultSkipped, equals(1));

      final failedLine = report.lineResults.firstWhere(
        (lineResult) => lineResult.input == '花开伊吕波',
      );
      expect(failedLine.status, PlainTextImportLineStatus.noResultSkipped);
      expect(failedLine.reason, startsWith('search request failed'));
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
