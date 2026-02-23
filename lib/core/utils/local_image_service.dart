import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:anime_shelf/core/database/app_database.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Result of downloading and processing a single subject's poster.
class LocalImageResult {
  final String thumbnailPath;
  final String largeImagePath;

  const LocalImageResult({
    required this.thumbnailPath,
    required this.largeImagePath,
  });
}

/// Service for downloading Bangumi poster images, generating local
/// thumbnails, and managing the on-device image cache.
///
/// Image files are stored under `{appDocDir}/posters/{subjectId}/`.
/// - `large.jpg`  — full-size image for the detail page.
/// - `thumb.jpg`  — compressed 220×320 thumbnail for the shelf.
class LocalImageService {
  /// Thumbnail dimensions (2x of the 110×160 card).
  static const _thumbWidth = 220;
  static const _thumbHeight = 320;
  static const _thumbQuality = 85;

  final AppDatabase _db;
  final Dio _dio;

  LocalImageService(this._db, this._dio);

  /// Downloads the poster for [subjectId], generates a thumbnail,
  /// saves both to disk, and updates the database paths.
  ///
  /// If [largeUrl] is empty, tries [mediumUrl] as fallback.
  /// Returns `null` if no URL is available or download fails.
  Future<LocalImageResult?> downloadAndProcess({
    required int subjectId,
    required String largeUrl,
    required String mediumUrl,
  }) async {
    final url = largeUrl.isNotEmpty ? largeUrl : mediumUrl;
    if (url.isEmpty) {
      return null;
    }

    try {
      // Download raw bytes
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        return null;
      }

      // Resolve storage directory
      final dir = await _posterDir(subjectId);
      final largePath = p.join(dir.path, 'large.jpg');
      final thumbPath = p.join(dir.path, 'thumb.jpg');

      // Write full-size image
      await File(largePath).writeAsBytes(bytes, flush: true);

      // Generate thumbnail in a background isolate
      final uint8Bytes = Uint8List.fromList(bytes);
      final thumbBytes = await Isolate.run(
        () => _generateThumbnail(uint8Bytes),
      );

      if (thumbBytes != null && thumbBytes.isNotEmpty) {
        await File(thumbPath).writeAsBytes(thumbBytes, flush: true);
      } else {
        // Fallback: use the large image as thumbnail too
        await File(thumbPath).writeAsBytes(bytes, flush: true);
      }

      // Update database
      await (_db.update(
        _db.subjects,
      )..where((s) => s.subjectId.equals(subjectId))).write(
        SubjectsCompanion(
          localThumbnailPath: Value(thumbPath),
          localLargeImagePath: Value(largePath),
        ),
      );

      return LocalImageResult(
        thumbnailPath: thumbPath,
        largeImagePath: largePath,
      );
    } catch (e) {
      log(
        'Failed to download/process poster for subject $subjectId: $e',
        name: 'LocalImageService',
      );
      return null;
    }
  }

  /// Deletes all locally cached poster files and clears DB paths.
  Future<int> clearAllLocalImages() async {
    final baseDir = await _postersBaseDir();
    var freedBytes = 0;

    if (await baseDir.exists()) {
      await for (final entity in baseDir.list(recursive: true)) {
        if (entity is File) {
          freedBytes += await entity.length();
        }
      }
      await baseDir.delete(recursive: true);
    }

    // Clear all local paths in DB
    await _db
        .update(_db.subjects)
        .write(
          const SubjectsCompanion(
            localThumbnailPath: Value(''),
            localLargeImagePath: Value(''),
          ),
        );

    return freedBytes;
  }

  /// Returns subjects that have a remote poster URL but no local files.
  Future<List<Subject>> subjectsMissingLocalImages() async {
    final query = _db.select(_db.subjects)
      ..where(
        (s) =>
            (s.posterUrl.length.isBiggerThanValue(0) |
                s.largePosterUrl.length.isBiggerThanValue(0)) &
            s.localThumbnailPath.equals(''),
      );
    return query.get();
  }

  /// Downloads images for all subjects missing local files.
  ///
  /// Processes up to [concurrency] downloads in parallel.
  /// Calls [onProgress] after each subject is processed.
  Future<int> redownloadAll({
    int concurrency = 3,
    void Function(int processed, int total)? onProgress,
  }) async {
    final subjects = await subjectsMissingLocalImages();
    if (subjects.isEmpty) {
      return 0;
    }

    var processed = 0;
    var succeeded = 0;

    for (var start = 0; start < subjects.length; start += concurrency) {
      final end = start + concurrency > subjects.length
          ? subjects.length
          : start + concurrency;
      final chunk = subjects.sublist(start, end);

      final results = await Future.wait(
        chunk.map(
          (s) => downloadAndProcess(
            subjectId: s.subjectId,
            largeUrl: s.largePosterUrl,
            mediumUrl: s.posterUrl,
          ),
        ),
      );

      for (final result in results) {
        processed++;
        if (result != null) {
          succeeded++;
        }
        onProgress?.call(processed, subjects.length);
      }
    }

    return succeeded;
  }

  /// Returns the base directory for all poster storage.
  Future<Directory> _postersBaseDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(p.join(appDir.path, 'posters'));
  }

  /// Returns (and creates) the directory for a specific subject's images.
  Future<Directory> _posterDir(int subjectId) async {
    final base = await _postersBaseDir();
    final dir = Directory(p.join(base.path, subjectId.toString()));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Pure function that decodes image bytes and generates a JPEG
  /// thumbnail. Runs in an isolate via [Isolate.run].
  static List<int>? _generateThumbnail(Uint8List sourceBytes) {
    try {
      final decoded = img.decodeImage(sourceBytes);
      if (decoded == null) {
        return null;
      }

      final resized = img.copyResize(
        decoded,
        width: _thumbWidth,
        height: _thumbHeight,
        interpolation: img.Interpolation.average,
      );

      return img.encodeJpg(resized, quality: _thumbQuality);
    } catch (_) {
      return null;
    }
  }
}
