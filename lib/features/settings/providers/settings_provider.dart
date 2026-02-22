import 'package:anime_shelf/core/providers.dart';
import 'package:anime_shelf/core/utils/export_service.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

/// Provides the export service instance.
@Riverpod(keepAlive: true)
ExportService exportService(ExportServiceRef ref) {
  return ExportService(
    ref.watch(databaseProvider),
    ref.watch(shelfRepositoryProvider),
  );
}
