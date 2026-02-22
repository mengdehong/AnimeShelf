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
  core/            # Shared: theme/, network/, database/, utils/
  models/          # Drift tables & data classes (tier, subject, entry, entry_subject)
  features/        # Feature modules: shelf/, search/, details/, settings/
  main.dart        # Entry point: DB init + ProviderScope
test/
  unit/            # Pure logic and repository tests
  widget/          # Widget tests
  integration/     # Integration / golden tests
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
