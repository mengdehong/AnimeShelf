import 'dart:async';

import 'package:anime_shelf/core/providers.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'details_provider.g.dart';

/// Watches a single entry with its primary subject for the detail page.
@riverpod
class EntryDetail extends _$EntryDetail {
  Timer? _debounce;

  @override
  Future<EntryWithSubject?> build(int entryId) async {
    ref.onDispose(() => _debounce?.cancel());
    return _fetchDetail();
  }

  Future<EntryWithSubject?> _fetchDetail() async {
    final db = ref.read(databaseProvider);
    final row = await (db.select(db.entries).join([
      innerJoin(
        db.subjects,
        db.subjects.subjectId.equalsExp(db.entries.primarySubjectId),
      ),
    ])..where(db.entries.id.equals(entryId))).getSingleOrNull();

    if (row == null) {
      return null;
    }
    return EntryWithSubject(
      entry: row.readTable(db.entries),
      subject: row.readTableOrNull(db.subjects),
    );
  }

  /// Debounced note update (800ms).
  void updateNote(String note) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      final repo = ref.read(shelfRepositoryProvider);
      await repo.updateNote(entryId: entryId, note: note);
    });
  }
}
