# AGENTS.md — AnimeShelf

## Project Overview

AnimeShelf is a local-first anime ranking/tier-list management app built with
**Flutter 3.x** (Dart). It targets Android and Linux desktop (Wayland-first).
Core stack: **Riverpod** (state), **Drift/SQLite** (persistence), **Dio** (HTTP),
**cached_network_image** (posters). See `docs/PROJECT.md` for the full blueprint.

---

## Build / Run / Test Commands

### Setup
```bash
flutter pub get                       # Install dependencies
dart run build_runner build --delete-conflicting-outputs  # Code-gen (Drift, Riverpod, Freezed)
```

### Build
```bash
flutter build apk --release           # Android APK
flutter build linux --release          # Linux desktop (produces bundle/)
```

### Run (development)
```bash
flutter run                            # Default connected device
flutter run -d linux                   # Run on Linux desktop
flutter run -d chrome                  # Web (if enabled)
```

### Lint & Format
```bash
dart analyze                           # Static analysis (uses analysis_options.yaml)
dart format .                          # Format all Dart files (80-char line width)
dart format --set-exit-if-changed .    # CI: fail on unformatted code
dart fix --apply                       # Apply automated lint fixes
```

### Tests
```bash
flutter test                                          # Run all tests
flutter test test/path/to/specific_test.dart          # Run a single test file
flutter test --name "description" test/path/file.dart # Run a single test by name
flutter test --coverage                               # Generate coverage report
flutter test --tags unit                              # Run only unit-tagged tests
flutter test --tags integration                       # Run only integration tests
```

### Code Generation (Drift, Riverpod, Freezed)
```bash
dart run build_runner build --delete-conflicting-outputs  # One-shot generation
dart run build_runner watch --delete-conflicting-outputs  # Watch mode
```

---

## Architecture

Feature-first layout with Repository pattern. See `docs/PROJECT.md` section III.

```
lib/
  core/
    database/
      app_database.dart       # Drift @DriftDatabase + seed tiers
      app_database.g.dart     # Generated Drift code
    exceptions/
      api_exception.dart      # ApiException, NetworkTimeoutException, NoConnectionException
      database_exception.dart # DatabaseException
    network/
      bangumi_client.dart     # Dio client with retry interceptor
    theme/
      app_theme.dart          # 3 themes: sakuraPink, bilibiliRed, dark
      theme_notifier.dart     # @riverpod ThemeNotifier + SharedPreferences
      theme_notifier.g.dart   # Generated
    utils/
      rank_utils.dart         # insertRank, needsRecompression, recompressRanks
      export_service.dart     # JSON/CSV/MD export + JSON import
    router.dart               # GoRouter: /shelf, /search, /details/:entryId, /settings
    providers.dart            # databaseProvider, bangumiClientProvider
    providers.g.dart          # Generated
  models/
    tier.dart                 # Drift Tiers table
    subject.dart              # Drift Subjects table (custom PK: subjectId)
    entry.dart                # Drift Entries table
    entry_subject.dart        # Drift EntrySubjects junction table
  features/
    shelf/
      data/shelf_repository.dart          # Full CRUD, rank math, watchTiersWithEntries
      providers/shelf_provider.dart       # shelfRepositoryProvider, shelfTiersProvider
      providers/shelf_provider.g.dart     # Generated
      ui/shelf_page.dart                  # Main page with ReorderableListView for tier drag
      ui/tier_section.dart                # DragTarget + LongPressDraggable for entries
      ui/entry_card.dart                  # Poster card with Hero tag
    search/
      data/bangumi_subject.dart           # @freezed BangumiSubject
      data/bangumi_subject.freezed.dart   # Generated
      data/bangumi_subject.g.dart         # Generated
      data/search_repository.dart         # Bangumi API search + local cache
      providers/search_provider.dart      # Debounced search provider
      providers/search_provider.g.dart    # Generated
      ui/search_page.dart                 # Search field + results + skeleton loading
      ui/add_to_shelf_sheet.dart          # Tier selection bottom sheet
    details/
      providers/details_provider.dart     # EntryDetail with debounced note save
      providers/details_provider.g.dart   # Generated
      ui/details_page.dart                # Glassmorphism + Hero + notes editor
    settings/
      providers/settings_provider.dart    # exportServiceProvider
      providers/settings_provider.g.dart  # Generated
      ui/settings_page.dart               # RadioGroup theme switcher + export/import
  main.dart                               # Entry point: ProviderScope + MaterialApp.router
test/
  unit/
    rank_utils_test.dart          # 23 tests — pure rank math logic
    shelf_repository_test.dart    # 17 tests — in-memory Drift DB
    export_service_test.dart      # 14 tests — JSON/CSV/MD round-trips
    search_repository_test.dart   # 9 tests — mocked Dio via mocktail
  widget/
    shelf_page_test.dart          # 14 tests — EntryCard + ShelfPage
  integration/                    # (placeholder — not yet populated)
```

---

## Code Style Guidelines

### Language & SDK
- Dart 3.x with sound null safety. Never use `dynamic` unless interfacing
  with raw JSON. Prefer strong typing everywhere.

### Formatting
- **Line width**: 80 characters (Dart default; enforced by `dart format`).
- **Trailing commas**: Always use trailing commas in argument lists, collection
  literals, and parameter lists. This produces cleaner diffs and auto-formatting.
- **Braces**: Always use braces for `if`/`else`/`for`/`while`, even single-line.

### Imports
- Order (enforced by `dart analyze`):
  1. `dart:` SDK imports
  2. `package:` third-party packages
  3. `package:anime_shelf/` project imports (relative within same feature OK)
- Separate each group with a blank line.
- Never use relative imports across feature boundaries — always use
  `package:anime_shelf/...`.
- Avoid `show`/`hide` unless resolving a name conflict.

### Naming Conventions
| Kind               | Convention          | Example                        |
|---------------------|---------------------|--------------------------------|
| Files / directories | `snake_case`        | `shelf_provider.dart`          |
| Classes / enums     | `PascalCase`        | `ShelfNotifier`, `TierColor`   |
| Variables / params  | `camelCase`         | `entryRank`, `primarySubjectId`|
| Constants           | `camelCase`         | `defaultTierGap = 1000`        |
| Private members     | `_camelCase`        | `_database`, `_fetchSubject()` |
| Providers           | `camelCase` + type  | `shelfProvider`, `searchProvider` |
| Drift tables        | `PascalCase` plural | `Entries`, `Tiers`, `Subjects` |

### Types & Null Safety
- Annotate return types on all public functions and methods.
- Use `required` for all named parameters that must be supplied.
- Prefer `final` for local variables that are not reassigned.
- Use `sealed class` or `enum` for finite state sets.
- Model async data with Riverpod's `AsyncValue<T>` — do not manually track
  loading/error/data booleans.

### State Management (Riverpod)
- Use `@riverpod` annotation with code generation (`riverpod_generator`).
- Keep providers in the same file as (or co-located with) the feature they serve
  under `features/<name>/providers/`.
- Prefer `AsyncNotifierProvider` for mutable async state; `Provider` for derived
  synchronous values.
- Never read providers inside `build()` without `ref.watch()` or `ref.listen()`.

### Database (Drift)
- Table definitions live in `lib/models/`. Generated code uses `.g.dart` suffix.
- Use `entryRank` / `tierSort` with double-precision floats for ordering.
  New rank = (prev + next) / 2. Re-rank when delta < 1e-9.
- Wrap multi-table mutations in `transaction()`.
- Repository classes live in `lib/features/<name>/data/` and accept the
  `AppDatabase` instance via constructor injection (provided through Riverpod).

### Networking (Dio)
- All Bangumi API requests must include header:
  `User-Agent: AnimeShelf/1.0 (https://github.com/your-repo/animeshelf)`
- Batch refresh concurrency cap: 3 concurrent requests.
- Retry with exponential backoff: 1s -> 2s -> 4s, max 3 attempts.
- Parse responses into typed Dart models; never pass raw `Map<String, dynamic>`
  beyond the repository layer.

### Error Handling
- Use Dart `Exception` subclasses, not `Error` (which is for programmer bugs).
- Define domain exceptions in `lib/core/exceptions/` (e.g., `ApiException`,
  `DatabaseException`).
- In repositories, catch Dio/Drift exceptions and rethrow as domain exceptions.
- In UI, handle errors via `AsyncValue.when()` — show user-friendly messages,
  never raw stack traces.
- Log errors with `dart:developer` `log()` in debug mode. Never use `print()`.

### Testing
- File naming: `<source_file>_test.dart`, mirroring the `lib/` structure.
- Use `setUp()` / `tearDown()` for shared state; prefer `setUpAll()` for
  expensive one-time setup (e.g., in-memory Drift DB).
- Mock dependencies with `mocktail` (preferred) or `mockito`.
- For Riverpod testing, use `ProviderContainer` overrides.
- Widget tests: use `pumpWidget()` with a `ProviderScope` wrapping the widget.
- Golden tests for visual regression (theme changes, layout).
- Aim for unit tests on all repository and provider logic; widget tests on
  key interaction flows.

### Comments & Documentation
- Use `///` doc comments on all public APIs (classes, methods, top-level funcs).
- Avoid redundant comments that restate the code. Comment *why*, not *what*.
- TODO format: `// TODO(username): description — #issue` (link issue if exists).

### Git Conventions
- Commit messages: `type: short description` (e.g., `feat: add tier drag-drop`,
  `fix: rank compression edge case`, `refactor: extract shelf repository`).
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`, `ci`.
- Keep commits atomic — one logical change per commit.

### Platform Considerations
- Linux desktop: GTK 3.x dependency (pre-installed on most distros).
  SQLite bundled via `sqlite3_flutter_libs`.
- Drag & drop: use Flutter native `Draggable`/`DragTarget` only — no
  third-party drag libraries.
- Mobile: long-press to initiate drag; edge auto-scroll during drag.
