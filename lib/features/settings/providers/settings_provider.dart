import 'dart:async';

import 'package:anime_shelf/core/providers.dart';
import 'package:anime_shelf/core/utils/export_service.dart';
import 'package:anime_shelf/features/search/providers/search_provider.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
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
  );
}

const plainTextImportMinConcurrency = 4;
const plainTextImportMaxConcurrency = 8;
const plainTextImportDefaultConcurrency = 6;

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
