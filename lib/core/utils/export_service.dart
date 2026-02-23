import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/features/search/data/bangumi_subject.dart';
import 'package:anime_shelf/features/search/data/search_repository.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Summary of a plain-text batch import.
class PlainTextImportReport {
  final int totalLines;
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

  const PlainTextImportReport({
    required this.totalLines,
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
  });
}

/// Service handling JSON/CSV/Markdown export and JSON import.
class ExportService {
  final AppDatabase _db;
  final ShelfRepository _shelfRepo;
  final SearchRepository? _searchRepo;

  ExportService(this._db, this._shelfRepo, {SearchRepository? searchRepo})
    : _searchRepo = searchRepo;

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
              'airDate': s.airDate,
              'eps': s.eps,
              'rating': s.rating,
              'summary': s.summary,
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
    buffer.writeln('Tier,Title,Original Title,Air Date,Rating,Note');

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

  // ── Markdown Export ──

  /// Exports shelf data as a Markdown document.
  Future<String> exportMarkdown() async {
    final tiersData = await _shelfRepo.watchTiersWithEntries().first;
    final buffer = StringBuffer();
    buffer.writeln('# AnimeShelf Export');
    buffer.writeln();
    buffer.writeln(
      '> Exported on ${DateTime.now().toIso8601String().substring(0, 10)}',
    );
    buffer.writeln();

    for (final tierData in tiersData) {
      final tier = tierData.tier;
      final emoji = tier.emoji.isNotEmpty ? '${tier.emoji} ' : '';
      buffer.writeln('## $emoji${tier.name}');
      buffer.writeln();

      if (tierData.entries.isEmpty) {
        buffer.writeln('*No entries*');
        buffer.writeln();
        continue;
      }

      for (final entryData in tierData.entries) {
        final s = entryData.subject;
        final title = (s?.nameCn.isNotEmpty == true)
            ? s!.nameCn
            : (s?.nameJp ?? 'Unknown');
        final year = (s?.airDate.length ?? 0) >= 4
            ? ' (${s!.airDate.substring(0, 4)})'
            : '';
        final ratingStr = (s?.rating ?? 0) > 0 ? ' — ${s!.rating}/10' : '';

        buffer.writeln('- **$title**$year$ratingStr');

        if (entryData.entry.note.isNotEmpty) {
          buffer.writeln('  > ${entryData.entry.note}');
        }
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Exports Markdown to a file and shares it.
  Future<void> exportMarkdownFile() async {
    final md = await exportMarkdown();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/animeshelf_export.md');
    await file.writeAsString(md);
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
                airDate: Value(map['airDate'] as String? ?? ''),
                eps: Value(map['eps'] as int? ?? 0),
                rating: Value((map['rating'] as num?)?.toDouble() ?? 0.0),
                summary: Value(map['summary'] as String? ?? ''),
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
  /// If an unknown tier header is encountered (for example `SS`),
  /// subsequent entries default to Inbox and are reported.
  ///
  /// Uses Bangumi search Top1 only when confidence is high; low-confidence
  /// matches are skipped and included in the report.
  Future<PlainTextImportReport> importPlainText(String text) async {
    final searchRepo = _searchRepo;
    if (searchRepo == null) {
      throw StateError('Search repository is not configured for text import.');
    }

    final tiers = await _db.select(_db.tiers).get();
    final inbox = tiers.firstWhere((tier) => tier.isInbox);
    final tiersByName = <String, Tier>{};
    for (final tier in tiers) {
      tiersByName[tier.name.trim().toLowerCase()] = tier;
    }

    final lines = text.split(RegExp(r'\r?\n'));

    var currentTier = inbox;
    String? activeUnknownTierHeader;

    var emptyLinesSkipped = 0;
    var tierHeadersDetected = 0;
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

    for (final rawLine in lines) {
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

      final results = await searchRepo.searchSubjects(trimmed, limit: 5);
      if (results.isEmpty) {
        noResultSkipped += 1;
        noResultEntries.add(trimmed);
        continue;
      }

      final top1 = results.first;
      final confidence = _evaluateTop1Confidence(trimmed, top1, results);
      if (!confidence.isHighConfidence) {
        lowConfidenceSkipped += 1;
        lowConfidenceEntries.add(
          '$trimmed -> ${_displayTitle(top1)} (${confidence.reason})',
        );
        continue;
      }

      final exists = await _shelfRepo.subjectExists(top1.id);
      if (exists) {
        duplicateSkipped += 1;
        duplicateEntries.add(trimmed);
        continue;
      }

      await searchRepo.cacheSubject(top1);
      await _shelfRepo.createEntry(subjectId: top1.id, tierId: currentTier.id);
      importedCount += 1;

      if (activeUnknownTierHeader != null) {
        inboxFallbackEntries.add(
          '$trimmed -> Inbox (unknown tier "$activeUnknownTierHeader")',
        );
      }
    }

    return PlainTextImportReport(
      totalLines: lines.length,
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
    );
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
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

  _MatchConfidence _evaluateTop1Confidence(
    String query,
    BangumiSubject top1,
    List<BangumiSubject> results,
  ) {
    final normalizedQuery = _normalizeForMatch(query);
    if (normalizedQuery.isEmpty) {
      return const _MatchConfidence.low('empty query');
    }

    final top1Score = _bestSimilarity(normalizedQuery, top1);
    final top1Exact = _isExactMatch(normalizedQuery, top1);
    final top1Contains = _isContainsMatch(normalizedQuery, top1);

    var top2Score = 0.0;
    if (results.length > 1) {
      top2Score = _bestSimilarity(normalizedQuery, results[1]);
    }

    if (top1Exact) {
      return const _MatchConfidence.high();
    }

    if (normalizedQuery.length <= 2) {
      return const _MatchConfidence.low('query too short');
    }

    final isTop1Strong =
        top1Score >= 0.86 ||
        (top1Contains && top1Score >= 0.72) ||
        (top1Score >= 0.78 && top2Score <= top1Score - 0.12);

    if (!isTop1Strong) {
      return _MatchConfidence.low(
        'low confidence ${top1Score.toStringAsFixed(2)}',
      );
    }

    final isAmbiguous = top2Score >= 0.75 && top2Score >= (top1Score - 0.05);
    if (isAmbiguous) {
      return const _MatchConfidence.low('ambiguous with close alternatives');
    }

    return const _MatchConfidence.high();
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
    return 'Unknown';
  }
}

class _MatchConfidence {
  final bool isHighConfidence;
  final String reason;

  const _MatchConfidence._({
    required this.isHighConfidence,
    required this.reason,
  });

  const _MatchConfidence.high() : this._(isHighConfidence: true, reason: 'ok');

  const _MatchConfidence.low(String reason)
    : this._(isHighConfidence: false, reason: reason);
}
