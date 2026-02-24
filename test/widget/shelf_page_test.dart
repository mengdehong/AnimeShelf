import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/providers.dart';
import 'package:anime_shelf/features/settings/providers/settings_provider.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:anime_shelf/features/shelf/ui/entry_card.dart';
import 'package:anime_shelf/features/shelf/ui/shelf_page.dart';
import 'package:anime_shelf/features/shelf/ui/tier_section.dart';
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

      // Top-ranked seed tiers should be visible.
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

    testWidgets('has tier reorder and settings action buttons', (tester) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.reorder), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
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

    testWidgets('tier reorder button opens manage order bottom sheet', (
      tester,
    ) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.reorder));
      await tester.pumpAndSettle();

      expect(find.text('Manage Tiers'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('New Tier'), findsOneWidget);

      await db.close();
    });

    testWidgets('manage sheet can stage a new tier before save', (
      tester,
    ) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.reorder));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'New Tier'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'S+');
      await tester.tap(find.text('Add to List'));
      await tester.pumpAndSettle();

      expect(find.text('S+'), findsOneWidget);
      expect(find.text('New tier (unsaved)'), findsOneWidget);

      await db.close();
    });

    testWidgets('empty tier renders without errors', (tester) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Inbox'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('搜索并添加动画即可开始'), findsOneWidget);
      expect(find.byType(TierSection), findsWidgets);

      await db.close();
    });

    testWidgets('tier header double tap shows edit dialog', (tester) async {
      final db = _createTestDb();

      await tester.pumpWidget(_testApp(child: const ShelfPage(), db: db));
      await tester.pumpAndSettle();

      // Double tap on a visible tier name.
      await tester.tap(find.text('SSS'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('SSS'));
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

  group('TierSection layout', () {
    testWidgets('uses configured shelf column count', (tester) async {
      final tier = Tier(
        id: 1,
        name: 'S',
        emoji: '',
        colorValue: 0xFFFF6B6B,
        tierSort: 3000,
        isInbox: false,
        createdAt: DateTime.now(),
      );
      final entries = <EntryWithSubject>[
        EntryWithSubject(
          entry: _fakeEntry(id: 1, tierId: tier.id, rank: 1000),
          subject: _fakeSubject(subjectId: 1, nameCn: 'A'),
        ),
        EntryWithSubject(
          entry: _fakeEntry(id: 2, tierId: tier.id, rank: 2000),
          subject: _fakeSubject(subjectId: 2, nameCn: 'B'),
        ),
        EntryWithSubject(
          entry: _fakeEntry(id: 3, tierId: tier.id, rank: 3000),
          subject: _fakeSubject(subjectId: 3, nameCn: 'C'),
        ),
        EntryWithSubject(
          entry: _fakeEntry(id: 4, tierId: tier.id, rank: 4000),
          subject: _fakeSubject(subjectId: 4, nameCn: 'D'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shelfEntryColumnsProvider.overrideWith(
              () => _FixedShelfEntryColumnsNotifier(4),
            ),
          ],
          child: _localizedMaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 360,
                  child: TierSection(tier: tier, entries: entries),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final cardBoxes = tester.widgetList<SizedBox>(
        find.byWidgetPredicate((widget) {
          return widget is SizedBox &&
              widget.width != null &&
              widget.height != null &&
              widget.child is RepaintBoundary;
        }),
      );

      expect(cardBoxes, isNotEmpty);
      final firstCard = cardBoxes.first;
      expect(firstCard.width, closeTo(68.5, 0.2));
    });

    testWidgets('entry title font shrinks when columns increase', (
      tester,
    ) async {
      final tier = Tier(
        id: 2,
        name: 'A',
        emoji: '',
        colorValue: 0xFF4ECDC4,
        tierSort: 4000,
        isInbox: false,
        createdAt: DateTime.now(),
      );
      final entries = <EntryWithSubject>[
        EntryWithSubject(
          entry: _fakeEntry(id: 10, tierId: tier.id, rank: 1000),
          subject: _fakeSubject(subjectId: 10, nameCn: 'FontScale'),
        ),
      ];

      Future<double> pumpAndGetTitleFontSize(int columns) async {
        await tester.pumpWidget(
          ProviderScope(
            key: ValueKey(columns),
            overrides: [
              shelfEntryColumnsProvider.overrideWith(
                () => _FixedShelfEntryColumnsNotifier(columns),
              ),
            ],
            child: _localizedMaterialApp(
              home: Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 360,
                    child: TierSection(tier: tier, entries: entries),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final titleText = tester.widget<Text>(find.text('FontScale').first);
        return titleText.style?.fontSize ?? 0;
      }

      final minColumnsSize = await pumpAndGetTitleFontSize(
        shelfEntryMinColumns,
      );
      final maxColumnsSize = await pumpAndGetTitleFontSize(
        shelfEntryMaxColumns,
      );

      expect(minColumnsSize, closeTo(10.5, 0.01));
      if (isDesktopPlatform) {
        expect(maxColumnsSize, closeTo(8.0, 0.01));
      } else {
        expect(maxColumnsSize, closeTo(7.5, 0.01));
      }
      expect(maxColumnsSize, lessThan(minColumnsSize));
    });
  });
}

class _FixedShelfEntryColumnsNotifier extends ShelfEntryColumnsNotifier {
  _FixedShelfEntryColumnsNotifier(this.columns);

  final int columns;

  @override
  int build() {
    return columns;
  }

  @override
  Future<void> setColumns(int value) async {}
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
