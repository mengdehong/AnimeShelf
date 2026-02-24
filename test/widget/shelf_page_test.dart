import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/providers.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:anime_shelf/features/shelf/ui/entry_card.dart';
import 'package:anime_shelf/features/shelf/ui/shelf_page.dart';
import 'package:anime_shelf/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Creates an in-memory [AppDatabase] for testing.
AppDatabase _createTestDb() => AppDatabase(NativeDatabase.memory());

/// Wraps [child] in a [MaterialApp] with [ProviderScope] overrides.
Widget _testApp({
  required Widget child,
  required AppDatabase db,
  List<Override> extraOverrides = const [],
}) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db), ...extraOverrides],
    child: _localizedMaterialApp(home: child),
  );
}

Widget _localizedMaterialApp({required Widget home}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('zh'),
    home: home,
  );
}

void main() {
  group('EntryCard', () {
    testWidgets('displays Chinese title when available', (tester) async {
      final entryData = EntryWithSubject(
        entry: _fakeEntry(id: 1, tierId: 1, rank: 1000.0),
        subject: _fakeSubject(
          subjectId: 42,
          nameCn: '命运石之门',
          nameJp: 'Steins;Gate',
        ),
      );

      await tester.pumpWidget(
        _localizedMaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 110,
              height: 160,
              child: EntryCard(entryData: entryData, onTap: () {}),
            ),
          ),
        ),
      );

      expect(find.text('命运石之门'), findsOneWidget);
    });

    testWidgets('falls back to Japanese title when Chinese is empty', (
      tester,
    ) async {
      final entryData = EntryWithSubject(
        entry: _fakeEntry(id: 1, tierId: 1, rank: 1000.0),
        subject: _fakeSubject(subjectId: 42, nameCn: '', nameJp: 'Steins;Gate'),
      );

      await tester.pumpWidget(
        _localizedMaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 110,
              height: 160,
              child: EntryCard(entryData: entryData, onTap: () {}),
            ),
          ),
        ),
      );

      expect(find.text('Steins;Gate'), findsOneWidget);
    });

    testWidgets('shows "未知" when no subject', (tester) async {
      final entryData = EntryWithSubject(
        entry: _fakeEntry(id: 1, tierId: 1, rank: 1000.0),
      );

      await tester.pumpWidget(
        _localizedMaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 110,
              height: 160,
              child: EntryCard(entryData: entryData, onTap: () {}),
            ),
          ),
        ),
      );

      expect(find.text('未知'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final entryData = EntryWithSubject(
        entry: _fakeEntry(id: 1, tierId: 1, rank: 1000.0),
        subject: _fakeSubject(subjectId: 42, nameCn: 'Test'),
      );

      await tester.pumpWidget(
        _localizedMaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 110,
              height: 160,
              child: EntryCard(
                entryData: entryData,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EntryCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows placeholder icon when no poster URL', (tester) async {
      final entryData = EntryWithSubject(
        entry: _fakeEntry(id: 1, tierId: 1, rank: 1000.0),
        subject: _fakeSubject(subjectId: 42, nameCn: 'Test', posterUrl: ''),
      );

      await tester.pumpWidget(
        _localizedMaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 110,
              height: 160,
              child: EntryCard(entryData: entryData, onTap: () {}),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
    });
  });

  group('ShelfPage', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await db.close();
    });

    testWidgets('displays seed tiers after loading', (tester) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      // Allow stream to emit
      await tester.pumpAndSettle();

      // Top tiers should be visible immediately.
      expect(find.text('SSS'), findsOneWidget);
      expect(find.text('SS'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);

      final seededTiers = await db.select(db.tiers).get();
      expect(seededTiers.length, equals(8));

      await db.close();
    });

    testWidgets('shows AppBar with search bar', (tester) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      expect(find.text('搜索 Bangumi...'), findsOneWidget);

      await db.close();
    });

    testWidgets('has tier reorder, add, and settings action buttons', (
      tester,
    ) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.reorder), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      await db.close();
    });

    testWidgets('has search bar that navigates to search page', (tester) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      // The search bar is embedded in the AppBar (no FAB).
      expect(find.text('搜索 Bangumi...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      await db.close();
    });

    testWidgets('AppBar add button opens add tier bottom sheet', (
      tester,
    ) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('新建分组'), findsOneWidget);
      expect(find.text('添加分组'), findsOneWidget);

      await db.close();
    });

    testWidgets('tier reorder button opens manage order bottom sheet', (
      tester,
    ) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.reorder));
      await tester.pumpAndSettle();

      expect(find.text('Manage Tier Order'), findsOneWidget);
      expect(find.text('Save Order'), findsOneWidget);

      await db.close();
    });

    testWidgets('empty tier shows placeholder text', (tester) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Inbox'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Inbox shows special message, other tiers show empty text.
      expect(find.text('搜索并添加动画即可开始'), findsOneWidget);
      expect(find.text(''), findsAtLeastNWidgets(3));

      await db.close();
    });

    testWidgets('tier header double tap shows edit dialog', (tester) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Inbox'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Double tap on a tier name (e.g. Inbox)
      await tester.tap(find.text('Inbox'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();

      expect(find.text('编辑分组'), findsOneWidget);

      await db.close();
    });

    testWidgets('non-inbox tiers have delete button in edit dialog', (
      tester,
    ) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      // Double tap a non-inbox tier (e.g. S)
      await tester.tap(find.text('S'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('S'));
      await tester.pumpAndSettle();

      // Dialog should have a delete button
      expect(find.byTooltip('删除分组'), findsOneWidget);

      await db.close();
    });
  });
}

// ── Fake data helpers ──

/// Creates a fake [Entry] data class for testing.
///
/// Uses a private constructor-like approach via Drift's generated class.
Entry _fakeEntry({
  required int id,
  required int tierId,
  required double rank,
  String note = '',
}) {
  return Entry(
    id: id,
    tierId: tierId,
    primarySubjectId: 1,
    entryRank: rank,
    note: note,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Creates a fake [Subject] for testing.
Subject _fakeSubject({
  required int subjectId,
  String nameCn = '',
  String nameJp = '',
  String posterUrl = '',
}) {
  return Subject(
    subjectId: subjectId,
    nameCn: nameCn,
    nameJp: nameJp,
    posterUrl: posterUrl,
    largePosterUrl: '',
    localThumbnailPath: '',
    localLargeImagePath: '',
    airDate: '',
    eps: 0,
    rating: 0.0,
    summary: '',
    tags: '',
    director: '',
    studio: '',
    globalRank: 0,
    lastFetchedAt: DateTime.now(),
  );
}
