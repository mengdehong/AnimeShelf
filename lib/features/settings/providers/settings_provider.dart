import 'dart:async';

import 'package:anime_shelf/core/providers.dart';
import 'package:anime_shelf/core/utils/export_service.dart';

import 'package:anime_shelf/features/search/providers/search_provider.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

/// Provides the export service instance.
@Riverpod(keepAlive: true)
ExportService exportService(ExportServiceRef ref) {
  return ExportService(
    ref.watch(databaseProvider),
    ref.watch(shelfRepositoryProvider),
    searchRepo: ref.watch(searchRepositoryProvider),
    imageService: ref.watch(localImageServiceProvider),
  );
}

const plainTextImportMinConcurrency = 4;
const plainTextImportMaxConcurrency = 8;
const plainTextImportDefaultConcurrency = 6;

const androidShelfEntryMinColumns = 3;
const androidShelfEntryMaxColumns = 6;
const androidShelfEntryDefaultColumns = 3;

const desktopShelfEntryMinColumns = 6;
const desktopShelfEntryMaxColumns = 12;
const desktopShelfEntryDefaultColumns = 8;

bool get isDesktopPlatform {
  if (kIsWeb) {
    return false;
  }

  final platform = defaultTargetPlatform;
  return platform == TargetPlatform.linux ||
      platform == TargetPlatform.macOS ||
      platform == TargetPlatform.windows;
}

int get shelfEntryMinColumns {
  return isDesktopPlatform
      ? desktopShelfEntryMinColumns
      : androidShelfEntryMinColumns;
}

int get shelfEntryMaxColumns {
  return isDesktopPlatform
      ? desktopShelfEntryMaxColumns
      : androidShelfEntryMaxColumns;
}

int get shelfEntryDefaultColumns {
  return isDesktopPlatform
      ? desktopShelfEntryDefaultColumns
      : androidShelfEntryDefaultColumns;
}

final shelfEntryColumnsProvider =
    NotifierProvider<ShelfEntryColumnsNotifier, int>(
      ShelfEntryColumnsNotifier.new,
    );

class ShelfEntryColumnsNotifier extends Notifier<int> {
  static const _key = 'shelf_entry_columns';

  @override
  int build() {
    unawaited(_loadSaved());
    return shelfEntryDefaultColumns;
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_key);
    if (saved == null) {
      return;
    }

    final bounded = _bounded(saved);
    if (bounded != state) {
      state = bounded;
    }
    if (bounded != saved) {
      await prefs.setInt(_key, bounded);
    }
  }

  Future<void> setColumns(int value) async {
    final bounded = _bounded(value);
    state = bounded;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, bounded);
  }

  int _bounded(int value) {
    return value.clamp(shelfEntryMinColumns, shelfEntryMaxColumns).toInt();
  }
}

final plainTextImportConcurrencyProvider =
    NotifierProvider<PlainTextImportConcurrencyNotifier, int>(
      PlainTextImportConcurrencyNotifier.new,
    );

class PlainTextImportConcurrencyNotifier extends Notifier<int> {
  static const _key = 'plain_text_import_concurrency';

  @override
  int build() {
    unawaited(_loadSaved());
    return plainTextImportDefaultConcurrency;
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_key);
    if (saved == null) {
      return;
    }

    final bounded = _bounded(saved);
    if (bounded != state) {
      state = bounded;
    }
    if (bounded != saved) {
      await prefs.setInt(_key, bounded);
    }
  }

  Future<void> setConcurrency(int value) async {
    final bounded = _bounded(value);
    state = bounded;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, bounded);
  }

  int _bounded(int value) {
    return value
        .clamp(plainTextImportMinConcurrency, plainTextImportMaxConcurrency)
        .toInt();
  }
}

enum PlainTextImportTaskStatus { idle, running, cancelling, completed, failed }

class PlainTextImportTaskState {
  final PlainTextImportTaskStatus status;
  final PlainTextImportProgress? progress;
  final PlainTextImportReport? report;
  final String? errorMessage;

  const PlainTextImportTaskState({
    this.status = PlainTextImportTaskStatus.idle,
    this.progress,
    this.report,
    this.errorMessage,
  });

  bool get isRunning {
    return status == PlainTextImportTaskStatus.running ||
        status == PlainTextImportTaskStatus.cancelling;
  }

  bool get canCancel => status == PlainTextImportTaskStatus.running;

  bool get showPanel => isRunning || report != null || errorMessage != null;

  PlainTextImportTaskState copyWith({
    PlainTextImportTaskStatus? status,
    PlainTextImportProgress? progress,
    PlainTextImportReport? report,
    String? errorMessage,
    bool clearReport = false,
    bool clearError = false,
  }) {
    return PlainTextImportTaskState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      report: clearReport ? null : (report ?? this.report),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final plainTextImportTaskProvider =
    NotifierProvider<PlainTextImportTaskNotifier, PlainTextImportTaskState>(
      PlainTextImportTaskNotifier.new,
    );

class PlainTextImportTaskNotifier extends Notifier<PlainTextImportTaskState> {
  PlainTextImportCancellationToken? _token;

  @override
  PlainTextImportTaskState build() {
    ref.onDispose(() {
      _token?.cancel();
    });

    return const PlainTextImportTaskState();
  }

  bool startImport(String content) {
    if (state.isRunning) {
      return false;
    }

    final token = PlainTextImportCancellationToken();
    _token = token;
    state = const PlainTextImportTaskState(
      status: PlainTextImportTaskStatus.running,
    );

    unawaited(_runImport(content, token));
    return true;
  }

  void cancelImport() {
    final token = _token;
    if (token == null || token.isCancelled) {
      return;
    }

    token.cancel();
    state = state.copyWith(status: PlainTextImportTaskStatus.cancelling);
  }

  void closePanel() {
    if (state.isRunning) {
      return;
    }

    state = const PlainTextImportTaskState();
  }

  Future<void> _runImport(
    String content,
    PlainTextImportCancellationToken token,
  ) async {
    try {
      final concurrency = ref.read(plainTextImportConcurrencyProvider);
      final report = await ref
          .read(exportServiceProvider)
          .importPlainText(
            content,
            searchConcurrency: concurrency,
            cancellationToken: token,
            onProgress: (progress) {
              if (!identical(_token, token)) {
                return;
              }

              state = state.copyWith(
                status: token.isCancelled
                    ? PlainTextImportTaskStatus.cancelling
                    : PlainTextImportTaskStatus.running,
                progress: progress,
              );
            },
          );

      if (!identical(_token, token)) {
        return;
      }

      _token = null;
      state = state.copyWith(
        status: PlainTextImportTaskStatus.completed,
        report: report,
      );
    } catch (error) {
      if (!identical(_token, token)) {
        return;
      }

      _token = null;
      state = state.copyWith(
        status: PlainTextImportTaskStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }
}

// ── Image Management Providers ──

enum ImageTaskStatus { idle, running, completed, failed }

class ImageTaskState {
  final ImageTaskStatus status;
  final int processed;
  final int total;
  final int succeeded;
  final String? errorMessage;

  const ImageTaskState({
    this.status = ImageTaskStatus.idle,
    this.processed = 0,
    this.total = 0,
    this.succeeded = 0,
    this.errorMessage,
  });

  bool get isRunning => status == ImageTaskStatus.running;

  bool get showPanel =>
      isRunning ||
      status == ImageTaskStatus.completed ||
      status == ImageTaskStatus.failed;

  double get progress => total == 0 ? 0.0 : (processed / total).clamp(0.0, 1.0);

  ImageTaskState copyWith({
    ImageTaskStatus? status,
    int? processed,
    int? total,
    int? succeeded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ImageTaskState(
      status: status ?? this.status,
      processed: processed ?? this.processed,
      total: total ?? this.total,
      succeeded: succeeded ?? this.succeeded,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final imageRedownloadTaskProvider =
    NotifierProvider<ImageRedownloadTaskNotifier, ImageTaskState>(
      ImageRedownloadTaskNotifier.new,
    );

class ImageRedownloadTaskNotifier extends Notifier<ImageTaskState> {
  @override
  ImageTaskState build() {
    return const ImageTaskState();
  }

  bool startRedownload() {
    if (state.isRunning) {
      return false;
    }

    state = const ImageTaskState(status: ImageTaskStatus.running);
    unawaited(_run());
    return true;
  }

  void closePanel() {
    if (state.isRunning) {
      return;
    }
    state = const ImageTaskState();
  }

  Future<void> _run() async {
    try {
      final imageService = ref.read(localImageServiceProvider);
      final succeeded = await imageService.redownloadAll(
        concurrency: 3,
        onProgress: (processed, total) {
          state = state.copyWith(processed: processed, total: total);
        },
      );

      state = state.copyWith(
        status: ImageTaskStatus.completed,
        succeeded: succeeded,
      );
    } catch (error) {
      state = state.copyWith(
        status: ImageTaskStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }
}
