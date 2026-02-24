import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/exceptions/api_exception.dart';
import 'package:anime_shelf/core/utils/local_image_service.dart';
import 'package:anime_shelf/features/search/data/bangumi_subject.dart';
import 'package:anime_shelf/features/search/data/search_repository.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Summary of a plain-text batch import.
enum PlainTextImportStage {
  preparing,
  searching,
  importing,
  completed,
  cancelled,
}

class PlainTextImportProgress {
  final PlainTextImportStage stage;
  final int totalEntries;
  final int searchedEntries;
  final int processedEntries;
  final int importedCount;
  final int failedCount;
  final String currentItem;
  final double progress;

  const PlainTextImportProgress({
    required this.stage,
    required this.totalEntries,
    required this.searchedEntries,
    required this.processedEntries,
    required this.importedCount,
    required this.failedCount,
    required this.currentItem,
    required this.progress,
  });
}

class PlainTextImportCancellationToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

enum PlainTextImportLineStatus {
  imported,
  duplicateSkipped,
  noResultSkipped,
  lowConfidenceSkipped,
  cancelled,
}

class PlainTextImportLineResult {
  final int lineNumber;
  final String input;
  final PlainTextImportLineStatus status;
  final String reason;
  final String? matchedTitle;
  final int? matchedSubjectId;
  final List<String> candidateTitles;

  const PlainTextImportLineResult({
    required this.lineNumber,
    required this.input,
    required this.status,
    required this.reason,
    required this.matchedTitle,
    required this.matchedSubjectId,
    required this.candidateTitles,
  });
}

class PlainTextImportReport {
  final int totalLines;
  final int totalEntries;
  final int processedEntries;
  final int emptyLinesSkipped;
  final int tierHeadersDetected;
  final int importedCount;
  final int duplicateSkipped;
  final int noResultSkipped;
  final int lowConfidenceSkipped;
  final List<String> unknownTierHeaders;
  final List<String> inboxFallbackEntries;
  final List<String> duplicateEntries;
  final List<String> noResultEntries;
  final List<String> lowConfidenceEntries;
  final List<String> importedEntries;
  final List<String> cancelledEntries;
  final List<PlainTextImportLineResult> lineResults;
  final bool cancelled;

  const PlainTextImportReport({
    required this.totalLines,
    required this.totalEntries,
    required this.processedEntries,
    required this.emptyLinesSkipped,
    required this.tierHeadersDetected,
    required this.importedCount,
    required this.duplicateSkipped,
    required this.noResultSkipped,
    required this.lowConfidenceSkipped,
    required this.unknownTierHeaders,
    required this.inboxFallbackEntries,
    required this.duplicateEntries,
    required this.noResultEntries,
    required this.lowConfidenceEntries,
    required this.importedEntries,
    required this.cancelledEntries,
    required this.lineResults,
    required this.cancelled,
  });
}

/// Service handling JSON/CSV/plain-text export and JSON import.
class ExportService {
  final AppDatabase _db;
  final ShelfRepository _shelfRepo;
  final SearchRepository? _searchRepo;
  final LocalImageService? _imageService;

  ExportService(
    this._db,
    this._shelfRepo, {
    SearchRepository? searchRepo,
    LocalImageService? imageService,
  }) : _searchRepo = searchRepo,
       _imageService = imageService;

  // ── JSON Export ──

  /// Exports all data as a JSON map.
  Future<Map<String, dynamic>> exportJson() async {
    final tiers = await _db.select(_db.tiers).get();
    final subjects = await _db.select(_db.subjects).get();
    final entries = await _db.select(_db.entries).get();
    final entrySubjects = await _db.select(_db.entrySubjects).get();

    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'tiers': tiers
          .map(
            (t) => {
              'id': t.id,
              'name': t.name,
              'emoji': t.emoji,
              'colorValue': t.colorValue,
              'tierSort': t.tierSort,
              'isInbox': t.isInbox,
            },
          )
          .toList(),
      'subjects': subjects
          .map(
            (s) => {
              'subjectId': s.subjectId,
              'nameCn': s.nameCn,
              'nameJp': s.nameJp,
              'posterUrl': s.posterUrl,
              'largePosterUrl': s.largePosterUrl,
              'airDate': s.airDate,
              'eps': s.eps,
              'rating': s.rating,
              'summary': s.summary,
              'tags': s.tags,
              'director': s.director,
              'studio': s.studio,
              'globalRank': s.globalRank,
              // localThumbnailPath and localLargeImagePath are
              // intentionally omitted — they are device-specific.
            },
          )
          .toList(),
      'entries': entries
          .map(
            (e) => {
              'id': e.id,
              'tierId': e.tierId,
              'primarySubjectId': e.primarySubjectId,
              'entryRank': e.entryRank,
              'note': e.note,
            },
          )
          .toList(),
      'entrySubjects': entrySubjects
          .map((es) => {'entryId': es.entryId, 'subjectId': es.subjectId})
          .toList(),
    };
  }

  /// Exports JSON data to a file and shares it.
  Future<void> exportJsonFile() async {
    final data = await exportJson();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/animeshelf_backup.json');
    await file.writeAsString(json);
    await Share.shareXFiles([XFile(file.path)]);
  }

  // ── CSV Export ──

  /// Exports shelf data as CSV.
  Future<String> exportCsv() async {
    final tiersData = await _shelfRepo.watchTiersWithEntries().first;
    final buffer = StringBuffer();
    buffer.writeln('分组,标题,原名,放送日期,评分,备注');

    for (final tierData in tiersData) {
      for (final entryData in tierData.entries) {
        final s = entryData.subject;
        buffer.writeln(
          '${_csvEscape(tierData.tier.name)},'
          '${_csvEscape(s?.nameCn ?? '')},'
          '${_csvEscape(s?.nameJp ?? '')},'
          '${_csvEscape(s?.airDate ?? '')},'
          '${s?.rating ?? ''},'
          '${_csvEscape(entryData.entry.note)}',
        );
      }
    }
    return buffer.toString();
  }

  /// Exports CSV to a file and shares it.
  Future<void> exportCsvFile() async {
    final csv = await exportCsv();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/animeshelf_export.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)]);
  }

  // ── Plain Text Export ──

  /// Exports shelf data as plain text.
  ///
  /// Output format follows plain-text import style:
  /// - Tier name on a standalone line
  /// - One anime title per line under the tier
  /// - Blank line between tiers
  Future<String> exportPlainText() async {
    final tiersData = await _shelfRepo.watchTiersWithEntries().first;
    final nonEmptyTiers = tiersData
        .where((tierData) => tierData.entries.isNotEmpty)
        .toList(growable: false);

    if (nonEmptyTiers.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (var i = 0; i < nonEmptyTiers.length; i++) {
      final tierData = nonEmptyTiers[i];
      buffer.writeln(tierData.tier.name);

      for (final entryData in tierData.entries) {
        buffer.writeln(_plainTextTitle(entryData.subject));
      }

      if (i < nonEmptyTiers.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  /// Exports plain text to a file and shares it.
  Future<void> exportPlainTextFile({String? content}) async {
    final text = content ?? await exportPlainText();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/animeshelf_export.txt');
    await file.writeAsString(text);
    await Share.shareXFiles([XFile(file.path)]);
  }

  // ── JSON Import ──

  /// Imports data from a JSON string (full replace).
  Future<void> importJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    await _db.transaction(() async {
      // Clear existing data
      await _db.delete(_db.entrySubjects).go();
      await _db.delete(_db.entries).go();
      await _db.delete(_db.subjects).go();
      await _db.delete(_db.tiers).go();

      // Import tiers
      final tiers = data['tiers'] as List<dynamic>;
      for (final t in tiers) {
        final map = t as Map<String, dynamic>;
        await _db
            .into(_db.tiers)
            .insert(
              TiersCompanion.insert(
                name: map['name'] as String,
                emoji: Value(map['emoji'] as String? ?? ''),
                colorValue: map['colorValue'] as int,
                tierSort: (map['tierSort'] as num).toDouble(),
                isInbox: Value(map['isInbox'] as bool? ?? false),
              ),
            );
      }

      // Import subjects
      final subjects = data['subjects'] as List<dynamic>;
      for (final s in subjects) {
        final map = s as Map<String, dynamic>;
        await _db
            .into(_db.subjects)
            .insert(
              SubjectsCompanion.insert(
                subjectId: Value(map['subjectId'] as int),
                nameCn: Value(map['nameCn'] as String? ?? ''),
                nameJp: Value(map['nameJp'] as String? ?? ''),
                posterUrl: Value(map['posterUrl'] as String? ?? ''),
                largePosterUrl: Value(map['largePosterUrl'] as String? ?? ''),
                // Local paths are device-specific; clear on import.
                localThumbnailPath: const Value(''),
                localLargeImagePath: const Value(''),
                airDate: Value(map['airDate'] as String? ?? ''),
                eps: Value(map['eps'] as int? ?? 0),
                rating: Value((map['rating'] as num?)?.toDouble() ?? 0.0),
                summary: Value(map['summary'] as String? ?? ''),
                tags: Value(map['tags'] as String? ?? ''),
                director: Value(map['director'] as String? ?? ''),
                studio: Value(map['studio'] as String? ?? ''),
                globalRank: Value(map['globalRank'] as int? ?? 0),
              ),
            );
      }

      // Import entries
      final entries = data['entries'] as List<dynamic>;
      for (final e in entries) {
        final map = e as Map<String, dynamic>;
        await _db
            .into(_db.entries)
            .insert(
              EntriesCompanion.insert(
                tierId: map['tierId'] as int,
                primarySubjectId: map['primarySubjectId'] as int,
                entryRank: (map['entryRank'] as num).toDouble(),
                note: Value(map['note'] as String? ?? ''),
              ),
            );
      }

      // Import entry_subjects
      final es = data['entrySubjects'] as List<dynamic>;
      for (final item in es) {
        final map = item as Map<String, dynamic>;
        await _db
            .into(_db.entrySubjects)
            .insert(
              EntrySubjectsCompanion.insert(
                entryId: map['entryId'] as int,
                subjectId: map['subjectId'] as int,
              ),
            );
      }
    });
  }

  /// Imports entries from plain text where each non-empty line is one anime.
  ///
  /// Tier headers can be specified as a standalone line, for example `S`.
  /// If an unknown tier header is encountered (for example `SSSS`),
  /// subsequent entries default to Inbox and are reported.
  ///
  /// Uses Bangumi search Top1 only when confidence is high; low-confidence
  /// matches are skipped and included in the report.
  Future<PlainTextImportReport> importPlainText(
    String text, {
    int searchConcurrency = 6,
    PlainTextImportCancellationToken? cancellationToken,
    void Function(PlainTextImportProgress progress)? onProgress,
  }) async {
    final searchRepo = _searchRepo;
    if (searchRepo == null) {
      throw StateError('Search repository is not configured for text import.');
    }

    final cancelToken = cancellationToken ?? PlainTextImportCancellationToken();

    final tiers = await _db.select(_db.tiers).get();
    final inbox = tiers.firstWhere((tier) => tier.isInbox);
    final tiersByName = <String, Tier>{};
    for (final tier in tiers) {
      tiersByName[tier.name.trim().toLowerCase()] = tier;
    }

    final lines = text.split(RegExp(r'\r?\n'));
    final importLines = <_PlainTextImportLine>[];
    final effectiveConcurrency = searchConcurrency.clamp(4, 8).toInt();

    var currentTier = inbox;
    String? activeUnknownTierHeader;

    var emptyLinesSkipped = 0;
    var tierHeadersDetected = 0;
    var searchedEntries = 0;
    var processedEntries = 0;
    var importedCount = 0;
    var duplicateSkipped = 0;
    var noResultSkipped = 0;
    var lowConfidenceSkipped = 0;

    final unknownTierHeaders = <String>[];
    final unknownTierHeaderSet = <String>{};
    final inboxFallbackEntries = <String>[];
    final duplicateEntries = <String>[];
    final noResultEntries = <String>[];
    final lowConfidenceEntries = <String>[];
    final importedEntries = <String>[];
    final cancelledEntries = <String>[];
    final lineResults = <PlainTextImportLineResult>[];
    final processedLineNumbers = <int>{};

    void emitProgress(PlainTextImportStage stage, {String currentItem = ''}) {
      if (onProgress == null) {
        return;
      }

      final totalEntries = importLines.length;
      final safeTotal = totalEntries == 0 ? 1 : totalEntries;
      const searchWeight = 0.65;
      const importWeight = 0.35;

      final searchRatio = searchedEntries / safeTotal;
      final importRatio = processedEntries / safeTotal;

      var progressValue =
          (searchRatio * searchWeight) + (importRatio * importWeight);
      if (stage == PlainTextImportStage.completed) {
        progressValue = 1.0;
      }

      onProgress(
        PlainTextImportProgress(
          stage: stage,
          totalEntries: totalEntries,
          searchedEntries: searchedEntries,
          processedEntries: processedEntries,
          importedCount: importedCount,
          failedCount:
              duplicateSkipped + noResultSkipped + lowConfidenceSkipped,
          currentItem: currentItem,
          progress: progressValue.clamp(0.0, 1.0).toDouble(),
        ),
      );
    }

    emitProgress(PlainTextImportStage.preparing);

    for (var i = 0; i < lines.length; i++) {
      final lineNumber = i + 1;
      final rawLine = lines[i];
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty) {
        emptyLinesSkipped += 1;
        continue;
      }

      final tierCandidate = _normalizeTierHeaderCandidate(trimmed);
      final knownTier = tiersByName[tierCandidate.toLowerCase()];
      if (knownTier != null) {
        currentTier = knownTier;
        activeUnknownTierHeader = null;
        tierHeadersDetected += 1;
        continue;
      }

      if (_looksLikeUnknownTierHeader(tierCandidate)) {
        currentTier = inbox;
        activeUnknownTierHeader = tierCandidate;
        if (unknownTierHeaderSet.add(tierCandidate)) {
          unknownTierHeaders.add(tierCandidate);
        }
        continue;
      }

      importLines.add(
        _PlainTextImportLine(
          lineNumber: lineNumber,
          query: trimmed,
          tierId: currentTier.id,
          unknownTierHeader: activeUnknownTierHeader,
        ),
      );
    }

    if (importLines.isNotEmpty) {
      final existingRows = await _db.select(_db.entrySubjects).get();
      final existingSubjectIds = existingRows
          .map((row) => row.subjectId)
          .toSet();

      emitProgress(PlainTextImportStage.searching);

      for (
        var start = 0;
        start < importLines.length;
        start += effectiveConcurrency
      ) {
        if (cancelToken.isCancelled) {
          break;
        }

        final end = min(start + effectiveConcurrency, importLines.length);
        final chunk = importLines.sublist(start, end);

        final chunkResolutions = await Future.wait(
          chunk.map((line) async {
            try {
              final results = await searchRepo.searchSubjects(
                line.query,
                limit: 5,
              );
              return _resolveSearchLine(line, results);
            } catch (error) {
              return _SearchResolution.noResult(
                line,
                reason: _searchFailureReason(error),
              );
            } finally {
              searchedEntries += 1;
              emitProgress(
                PlainTextImportStage.searching,
                currentItem: line.query,
              );
            }
          }),
        );

        for (final resolution in chunkResolutions) {
          final line = resolution.line;
          if (cancelToken.isCancelled) {
            break;
          }

          final candidateTitles = resolution.candidateTitles;

          if (resolution.status == _SearchResolutionStatus.noResult) {
            noResultSkipped += 1;
            processedEntries += 1;
            processedLineNumbers.add(line.lineNumber);

            final reason = resolution.reason ?? 'no result from Bangumi search';
            if (reason.startsWith('search request failed')) {
              noResultEntries.add(
                'L${line.lineNumber}: ${line.query} ($reason)',
              );
            } else {
              noResultEntries.add('L${line.lineNumber}: ${line.query}');
            }

            lineResults.add(
              PlainTextImportLineResult(
                lineNumber: line.lineNumber,
                input: line.query,
                status: PlainTextImportLineStatus.noResultSkipped,
                reason: reason,
                matchedTitle: null,
                matchedSubjectId: null,
                candidateTitles: candidateTitles,
              ),
            );

            emitProgress(
              PlainTextImportStage.importing,
              currentItem: line.query,
            );
            continue;
          }

          final top1 = resolution.top1;
          if (resolution.status == _SearchResolutionStatus.lowConfidence ||
              top1 == null) {
            lowConfidenceSkipped += 1;
            processedEntries += 1;
            processedLineNumbers.add(line.lineNumber);

            final displayTitle = top1 != null ? _displayTitle(top1) : '未知';
            final reason = resolution.reason ?? 'low confidence';
            lowConfidenceEntries.add(
              'L${line.lineNumber}: ${line.query} -> '
              '$displayTitle ($reason)',
            );

            lineResults.add(
              PlainTextImportLineResult(
                lineNumber: line.lineNumber,
                input: line.query,
                status: PlainTextImportLineStatus.lowConfidenceSkipped,
                reason: reason,
                matchedTitle: top1 != null ? _displayTitle(top1) : null,
                matchedSubjectId: top1?.id,
                candidateTitles: candidateTitles,
              ),
            );

            emitProgress(
              PlainTextImportStage.importing,
              currentItem: line.query,
            );
            continue;
          }

          final matchedTitle = _displayTitle(top1);
          if (existingSubjectIds.contains(top1.id)) {
            duplicateSkipped += 1;
            processedEntries += 1;
            processedLineNumbers.add(line.lineNumber);
            duplicateEntries.add(
              'L${line.lineNumber}: ${line.query} -> $matchedTitle',
            );

            lineResults.add(
              PlainTextImportLineResult(
                lineNumber: line.lineNumber,
                input: line.query,
                status: PlainTextImportLineStatus.duplicateSkipped,
                reason: 'already exists in shelf',
                matchedTitle: matchedTitle,
                matchedSubjectId: top1.id,
                candidateTitles: candidateTitles,
              ),
            );

            emitProgress(
              PlainTextImportStage.importing,
              currentItem: line.query,
            );
            continue;
          }

          await searchRepo.cacheSubject(top1);
          await _shelfRepo.createEntry(subjectId: top1.id, tierId: line.tierId);

          // Queue background image download (fire-and-forget).
          unawaited(
            _imageService?.downloadAndProcess(
              subjectId: top1.id,
              largeUrl: top1.images?.large ?? '',
              mediumUrl: top1.images?.medium ?? '',
            ),
          );

          existingSubjectIds.add(top1.id);
          importedCount += 1;
          processedEntries += 1;
          processedLineNumbers.add(line.lineNumber);
          importedEntries.add(
            'L${line.lineNumber}: ${line.query} -> $matchedTitle',
          );

          lineResults.add(
            PlainTextImportLineResult(
              lineNumber: line.lineNumber,
              input: line.query,
              status: PlainTextImportLineStatus.imported,
              reason: 'imported',
              matchedTitle: matchedTitle,
              matchedSubjectId: top1.id,
              candidateTitles: candidateTitles,
            ),
          );

          if (line.unknownTierHeader != null) {
            inboxFallbackEntries.add(
              'L${line.lineNumber}: ${line.query} -> '
              'Inbox (unknown tier "${line.unknownTierHeader}")',
            );
          }

          emitProgress(PlainTextImportStage.importing, currentItem: line.query);
        }
      }
    }

    if (cancelToken.isCancelled) {
      for (final line in importLines) {
        if (processedLineNumbers.contains(line.lineNumber)) {
          continue;
        }

        cancelledEntries.add('L${line.lineNumber}: ${line.query}');
        lineResults.add(
          PlainTextImportLineResult(
            lineNumber: line.lineNumber,
            input: line.query,
            status: PlainTextImportLineStatus.cancelled,
            reason: 'cancelled by user',
            matchedTitle: null,
            matchedSubjectId: null,
            candidateTitles: const [],
          ),
        );
      }
    }

    emitProgress(
      cancelToken.isCancelled
          ? PlainTextImportStage.cancelled
          : PlainTextImportStage.completed,
    );

    return PlainTextImportReport(
      totalLines: lines.length,
      totalEntries: importLines.length,
      processedEntries: processedEntries,
      emptyLinesSkipped: emptyLinesSkipped,
      tierHeadersDetected: tierHeadersDetected,
      importedCount: importedCount,
      duplicateSkipped: duplicateSkipped,
      noResultSkipped: noResultSkipped,
      lowConfidenceSkipped: lowConfidenceSkipped,
      unknownTierHeaders: unknownTierHeaders,
      inboxFallbackEntries: inboxFallbackEntries,
      duplicateEntries: duplicateEntries,
      noResultEntries: noResultEntries,
      lowConfidenceEntries: lowConfidenceEntries,
      importedEntries: importedEntries,
      cancelledEntries: cancelledEntries,
      lineResults: lineResults,
      cancelled: cancelToken.isCancelled,
    );
  }

  String _searchFailureReason(Object error) {
    if (error is NetworkTimeoutException) {
      return 'search request failed: timeout';
    }
    if (error is NoConnectionException) {
      return 'search request failed: no internet connection';
    }
    if (error is ApiException) {
      final statusCode = error.statusCode;
      if (statusCode != null) {
        return 'search request failed: api status $statusCode';
      }
      return 'search request failed: api error';
    }
    return 'search request failed';
  }

  _SearchResolution _resolveSearchLine(
    _PlainTextImportLine line,
    List<BangumiSubject> results,
  ) {
    if (results.isEmpty) {
      return _SearchResolution.noResult(line);
    }

    BangumiSubject? bestSubject;
    var highestScore = 0.0;
    BangumiSubject? strongestSeasonMismatchSubject;
    String? strongestSeasonMismatchReason;
    var strongestSeasonMismatchScore = 0.0;

    final searchLimit = min(results.length, 4);
    for (var i = 0; i < searchLimit; i++) {
      final candidate = results[i];
      final score = _evaluateCandidateScore(line.query, candidate, i);
      final mismatch = _seasonMismatchReason(line.query, candidate);
      if (mismatch != null) {
        if (score > strongestSeasonMismatchScore) {
          strongestSeasonMismatchScore = score;
          strongestSeasonMismatchSubject = candidate;
          strongestSeasonMismatchReason = mismatch;
        }
        continue;
      }

      if (score > highestScore) {
        highestScore = score;
        bestSubject = candidate;
      }
    }

    if (bestSubject == null) {
      final mismatchSubject = strongestSeasonMismatchSubject;
      final mismatchReason = strongestSeasonMismatchReason;
      if (mismatchSubject != null && mismatchReason != null) {
        return _SearchResolution.lowConfidence(
          line,
          mismatchSubject,
          results,
          mismatchReason,
        );
      }

      final top1 = results.first;
      return _SearchResolution.lowConfidence(
        line,
        top1,
        results,
        'no suitable match found',
      );
    }

    // Threshold for accepting a match
    if (highestScore < 0.78) {
      final mismatchSubject = strongestSeasonMismatchSubject;
      final mismatchReason = strongestSeasonMismatchReason;
      final mismatchDominates =
          mismatchSubject != null &&
          mismatchReason != null &&
          strongestSeasonMismatchScore >= 0.78 &&
          strongestSeasonMismatchScore > (highestScore + 0.08);
      if (mismatchDominates) {
        return _SearchResolution.lowConfidence(
          line,
          mismatchSubject,
          results,
          mismatchReason,
        );
      }

      return _SearchResolution.lowConfidence(
        line,
        bestSubject,
        results,
        'low confidence match (score: ${highestScore.toStringAsFixed(2)})',
      );
    }

    return _SearchResolution.matched(line, bestSubject, results);
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _plainTextTitle(Subject? subject) {
    if (subject == null) {
      return '未知';
    }

    if (subject.nameCn.isNotEmpty) {
      return subject.nameCn;
    }

    if (subject.nameJp.isNotEmpty) {
      return subject.nameJp;
    }

    return '未知';
  }

  String _normalizeTierHeaderCandidate(String line) {
    final trimmed = line.trim();
    if (trimmed.endsWith(':')) {
      return trimmed.substring(0, trimmed.length - 1).trim();
    }
    return trimmed;
  }

  bool _looksLikeUnknownTierHeader(String value) {
    if (value.isEmpty || value.contains(' ')) {
      return false;
    }

    final upper = value.toUpperCase();

    final basicTierLike = RegExp(r'^[SABCDEF][+-]?$').hasMatch(upper);
    if (basicTierLike) {
      return true;
    }

    final sameLetterTierLike =
        RegExp(r'^[SABCDEF]{2,4}$').hasMatch(upper) &&
        upper.split('').toSet().length == 1;
    if (sameLetterTierLike) {
      return true;
    }

    return RegExp(r'^[SABCDEF][0-9]$').hasMatch(upper);
  }

  String? _seasonMismatchReason(String query, BangumiSubject top1) {
    final seasonNumber = _extractSeasonNumber(query);
    if (seasonNumber == null || seasonNumber <= 1) {
      return null;
    }

    final normalizedQuery = _normalizeForMatch(query);
    final normalizedCn = _normalizeForMatch(top1.nameCn);
    final normalizedName = _normalizeForMatch(top1.name);

    final isDirectTitleMatch =
        normalizedQuery == normalizedCn || normalizedQuery == normalizedName;
    if (isDirectTitleMatch) {
      return null;
    }

    final hasSeasonToken =
        _containsSeasonToken(normalizedCn, seasonNumber) ||
        _containsSeasonToken(normalizedName, seasonNumber);
    if (hasSeasonToken) {
      return null;
    }

    return 'season indicator mismatch (wanted season $seasonNumber)';
  }

  int? _extractSeasonNumber(String query) {
    final compact = query.toLowerCase().replaceAll(RegExp(r'\s+'), '');

    final explicitArabic = RegExp(r'第([0-9]{1,2})[季期部篇章]').firstMatch(compact);
    if (explicitArabic != null) {
      return int.tryParse(explicitArabic.group(1) ?? '');
    }

    final explicitChinese = RegExp(
      r'第([一二三四五六七八九十两]{1,3})[季期部篇章]',
    ).firstMatch(compact);
    if (explicitChinese != null) {
      return _parseChineseNumber(explicitChinese.group(1) ?? '');
    }

    final seasonEnglish = RegExp(r'season([0-9]{1,2})').firstMatch(compact);
    if (seasonEnglish != null) {
      return int.tryParse(seasonEnglish.group(1) ?? '');
    }

    final suffixNumber = RegExp(r'([0-9]{1,2})$').firstMatch(compact);
    if (suffixNumber == null) {
      return null;
    }

    final parsed = int.tryParse(suffixNumber.group(1) ?? '');
    final hasCjk = RegExp(r'[\u4e00-\u9fff]').hasMatch(compact);
    if (!hasCjk || parsed == null || parsed < 2 || parsed > 9) {
      return null;
    }

    return parsed;
  }

  int? _parseChineseNumber(String value) {
    const map = {
      '零': 0,
      '一': 1,
      '二': 2,
      '两': 2,
      '三': 3,
      '四': 4,
      '五': 5,
      '六': 6,
      '七': 7,
      '八': 8,
      '九': 9,
      '十': 10,
    };

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed == '十') {
      return 10;
    }

    if (trimmed.contains('十')) {
      final parts = trimmed.split('十');
      final tensPart = parts.first;
      final onesPart = parts.length > 1 ? parts.last : '';

      final tens = tensPart.isEmpty ? 1 : map[tensPart];
      final ones = onesPart.isEmpty ? 0 : map[onesPart];

      if (tens == null || ones == null) {
        return null;
      }
      return (tens * 10) + ones;
    }

    return map[trimmed];
  }

  String _toChineseSeasonNumber(int value) {
    const digits = {
      0: '零',
      1: '一',
      2: '二',
      3: '三',
      4: '四',
      5: '五',
      6: '六',
      7: '七',
      8: '八',
      9: '九',
      10: '十',
    };

    if (value <= 10) {
      return digits[value] ?? value.toString();
    }
    if (value < 20) {
      return '十${digits[value - 10] ?? ''}';
    }
    if (value == 20) {
      return '二十';
    }
    return value.toString();
  }

  bool _containsSeasonToken(String normalizedTitle, int seasonNumber) {
    if (normalizedTitle.isEmpty) {
      return false;
    }

    final arabic = seasonNumber.toString();
    final chinese = _toChineseSeasonNumber(seasonNumber);

    final rawTokens = <String>[
      '第$arabic季',
      '第$arabic期',
      '第$arabic部',
      '第$arabic篇',
      '$arabic季',
      '$arabic期',
      '$arabic部',
      '$arabic篇',
      'season$arabic',
      's$arabic',
      '第$chinese季',
      '第$chinese期',
      '第$chinese部',
      '第$chinese篇',
      '$chinese季',
      '$chinese期',
      '$chinese部',
      '$chinese篇',
    ];

    for (final token in rawTokens) {
      final normalizedToken = _normalizeForMatch(token);
      if (normalizedToken.isNotEmpty &&
          normalizedTitle.contains(normalizedToken)) {
        return true;
      }
    }

    return false;
  }

  double _evaluateCandidateScore(
    String query,
    BangumiSubject candidate,
    int rankIndex,
  ) {
    final normalizedQuery = _normalizeForMatch(query);
    if (normalizedQuery.isEmpty) {
      return 0.0;
    }

    final textScore = _bestSimilarity(normalizedQuery, candidate);
    final isExact = _isExactMatch(normalizedQuery, candidate);
    final isContains = _isContainsMatch(normalizedQuery, candidate);

    final votes = candidate.rating?.total ?? 0;
    var popBoost = 0.0;
    if (votes > 500) popBoost += 0.05;
    if (votes > 2000) popBoost += 0.05;
    if (votes > 10000) popBoost += 0.05;

    var rankBoost = 0.0;
    if (rankIndex == 0) {
      rankBoost = 0.15;
    } else if (rankIndex == 1) {
      rankBoost = 0.05;
    }

    var score = textScore;
    if (isExact) {
      score = 1.0;
    } else if (isContains && normalizedQuery.length >= 2) {
      score = max(score, 0.70 + (textScore * 0.1));
    }

    final hasCjk = RegExp(r'[\u4e00-\u9fff]').hasMatch(normalizedQuery);
    final isAliasCandidate =
        rankIndex == 0 &&
        (hasCjk
            ? (normalizedQuery.length >= 3 ||
                  (normalizedQuery.length == 2 && votes >= 8000))
            : normalizedQuery.length >= 4);

    if (!isExact && !isContains && isAliasCandidate) {
      score = max(score, 0.50 + (textScore * 0.5));
    }

    return score + popBoost + rankBoost;
  }

  double _bestSimilarity(String normalizedQuery, BangumiSubject subject) {
    final nameCn = _normalizeForMatch(subject.nameCn);
    final name = _normalizeForMatch(subject.name);
    return max(
      _normalizedSimilarity(normalizedQuery, nameCn),
      _normalizedSimilarity(normalizedQuery, name),
    );
  }

  bool _isExactMatch(String normalizedQuery, BangumiSubject subject) {
    final nameCn = _normalizeForMatch(subject.nameCn);
    final name = _normalizeForMatch(subject.name);
    return normalizedQuery == nameCn || normalizedQuery == name;
  }

  bool _isContainsMatch(String normalizedQuery, BangumiSubject subject) {
    final nameCn = _normalizeForMatch(subject.nameCn);
    final name = _normalizeForMatch(subject.name);
    return _containsEitherWay(normalizedQuery, nameCn) ||
        _containsEitherWay(normalizedQuery, name);
  }

  bool _containsEitherWay(String a, String b) {
    if (a.isEmpty || b.isEmpty) {
      return false;
    }
    return a.contains(b) || b.contains(a);
  }

  String _normalizeForMatch(String value) {
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();

    for (final rune in lower.runes) {
      if (_isMatchRune(rune)) {
        buffer.write(String.fromCharCode(rune));
      }
    }

    return buffer.toString();
  }

  bool _isMatchRune(int rune) {
    final isDigit = rune >= 0x30 && rune <= 0x39;
    final isAsciiLower = rune >= 0x61 && rune <= 0x7A;
    final isCjk = rune >= 0x4E00 && rune <= 0x9FFF;
    final isHiragana = rune >= 0x3040 && rune <= 0x309F;
    final isKatakana = rune >= 0x30A0 && rune <= 0x30FF;

    return isDigit || isAsciiLower || isCjk || isHiragana || isKatakana;
  }

  double _normalizedSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) {
      return 0.0;
    }
    if (a == b) {
      return 1.0;
    }
    final distance = _levenshteinDistance(a, b);
    final maxLen = max(a.length, b.length);
    return 1.0 - (distance / maxLen);
  }

  int _levenshteinDistance(String a, String b) {
    final m = a.length;
    final n = b.length;
    if (m == 0) {
      return n;
    }
    if (n == 0) {
      return m;
    }

    var previous = List<int>.generate(n + 1, (index) => index);
    var current = List<int>.filled(n + 1, 0);

    for (var i = 1; i <= m; i++) {
      current[0] = i;
      final codeA = a.codeUnitAt(i - 1);
      for (var j = 1; j <= n; j++) {
        final cost = codeA == b.codeUnitAt(j - 1) ? 0 : 1;
        final deletion = previous[j] + 1;
        final insertion = current[j - 1] + 1;
        final substitution = previous[j - 1] + cost;
        current[j] = min(deletion, min(insertion, substitution));
      }

      final swap = previous;
      previous = current;
      current = swap;
    }

    return previous[n];
  }

  String _displayTitle(BangumiSubject subject) {
    if (subject.nameCn.isNotEmpty) {
      return subject.nameCn;
    }
    if (subject.name.isNotEmpty) {
      return subject.name;
    }
    return '未知';
  }
}

class _PlainTextImportLine {
  final int lineNumber;
  final String query;
  final int tierId;
  final String? unknownTierHeader;

  const _PlainTextImportLine({
    required this.lineNumber,
    required this.query,
    required this.tierId,
    required this.unknownTierHeader,
  });
}

enum _SearchResolutionStatus { matched, noResult, lowConfidence }

class _SearchResolution {
  final _PlainTextImportLine line;
  final _SearchResolutionStatus status;
  final BangumiSubject? top1;
  final String? reason;
  final List<String> candidateTitles;

  const _SearchResolution._({
    required this.line,
    required this.status,
    required this.top1,
    required this.reason,
    required this.candidateTitles,
  });

  factory _SearchResolution.noResult(
    _PlainTextImportLine line, {
    String reason = 'no result from Bangumi search',
  }) {
    return _SearchResolution._(
      line: line,
      status: _SearchResolutionStatus.noResult,
      top1: null,
      reason: reason,
      candidateTitles: const [],
    );
  }

  factory _SearchResolution.lowConfidence(
    _PlainTextImportLine line,
    BangumiSubject top1,
    List<BangumiSubject> results,
    String reason,
  ) {
    return _SearchResolution._(
      line: line,
      status: _SearchResolutionStatus.lowConfidence,
      top1: top1,
      reason: reason,
      candidateTitles: _candidateTitles(results),
    );
  }

  factory _SearchResolution.matched(
    _PlainTextImportLine line,
    BangumiSubject top1,
    List<BangumiSubject> results,
  ) {
    return _SearchResolution._(
      line: line,
      status: _SearchResolutionStatus.matched,
      top1: top1,
      reason: null,
      candidateTitles: _candidateTitles(results),
    );
  }

  static List<String> _candidateTitles(List<BangumiSubject> results) {
    return results
        .take(3)
        .map((subject) {
          if (subject.nameCn.isNotEmpty) {
            return '${subject.nameCn} (#${subject.id})';
          }
          if (subject.name.isNotEmpty) {
            return '${subject.name} (#${subject.id})';
          }
          return '#${subject.id}';
        })
        .toList(growable: false);
  }
}
