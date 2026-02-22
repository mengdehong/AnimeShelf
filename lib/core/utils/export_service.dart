import 'dart:convert';
import 'dart:io';

import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service handling JSON/CSV/Markdown export and JSON import.
class ExportService {
  final AppDatabase _db;
  final ShelfRepository _shelfRepo;

  ExportService(this._db, this._shelfRepo);

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

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
