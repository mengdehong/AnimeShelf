# AnimeShelf

A local-first anime ranking and tier-list management app built with Flutter.
Organize your anime collection using drag-and-drop tiers powered by
[Bangumi](https://bgm.tv) metadata.

## Features

- **Tier-based shelf** — Drag entries between custom tiers (SS, S, A, B, C, …).
  Reorder tiers and entries with long-press drag-and-drop.
- **Bangumi search** — Search and collect anime directly from the Bangumi API.
  Skeleton loading while network requests are in flight.
- **Immersive details page** — Hero animation + glassmorphism overlay.
  Write private notes (stored locally, never uploaded).
- **Export / Import** — Full data backup as JSON (`.animeshelf`), CSV for
  spreadsheet workflows, and Markdown for blog posts.
- **Themes** — Sakura Pink, Bilibili Red, and Dark mode.
- **Offline-first** — All shelf data lives in a local SQLite database via Drift.
  Bangumi metadata is cached locally for offline browsing.

## Tech Stack

| Layer          | Library                                         |
|----------------|-------------------------------------------------|
| UI framework   | Flutter 3.x (Dart 3.x)                          |
| State          | `hooks_riverpod` + `riverpod_generator`         |
| Database       | `drift` / SQLite (`sqlite3_flutter_libs`)        |
| HTTP           | `dio` with retry interceptor                    |
| Images         | `cached_network_image`                          |
| Routing        | `go_router`                                     |
| Serialization  | `freezed` + `json_serializable`                 |
| Export/share   | `share_plus`, `path_provider`                   |

## Platforms

- **Android** (primary)
- **Linux desktop** — Wayland-first, GTK 3.x (pre-installed on most distros).
  Distributed as a `bundle/` directory (`flutter build linux --release`).

## Getting Started

### Prerequisites

- Flutter 3.x SDK (`flutter --version`)
- For Linux desktop: GTK 3 dev headers (`libgtk-3-dev` on Debian/Ubuntu)

### Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Run

```bash
flutter run -d linux    # Linux desktop
flutter run             # Android (connected device / emulator)
```

### Build

```bash
flutter build linux --release   # Linux bundle in build/linux/x64/release/bundle/
flutter build apk --release     # Android APK in build/app/outputs/flutter-apk/
```

### Lint & Format

```bash
dart analyze
dart format .
```

### Test

```bash
flutter test             # 77 tests (unit + widget)
flutter test --coverage  # with coverage report
```

## Architecture

Feature-first layout with Repository pattern:

```
lib/
  core/
    database/        # Drift AppDatabase + seed data
    exceptions/      # ApiException, DatabaseException
    network/         # BangumiClient (Dio + retry)
    theme/           # AppTheme (3 themes) + ThemeNotifier
    utils/           # RankUtils (float-bisect ordering), ExportService
    router.dart      # GoRouter: /shelf /search /details/:id /settings
    providers.dart   # databaseProvider, bangumiClientProvider
  models/            # Drift table definitions: Tiers, Subjects, Entries, EntrySubjects
  features/
    shelf/           # ShelfRepository, ShelfPage, TierSection, EntryCard
    search/          # BangumiSubject (freezed), SearchRepository, SearchPage
    details/         # DetailsPage (Hero + glassmorphism + notes)
    settings/        # SettingsPage (themes, export/import)
test/
  unit/              # RankUtils, ShelfRepository, ExportService, SearchRepository
  widget/            # ShelfPage, EntryCard
```

### Rank ordering

Entries and tiers are ordered using **float-bisect insertion**:
`newRank = (prevRank + nextRank) / 2`. Recompression triggers when the delta
between adjacent ranks falls below `1e-9`.

## Project Blueprint

See [`docs/PROJECT.md`](docs/PROJECT.md) for the full product and architecture
specification (written in Chinese).
