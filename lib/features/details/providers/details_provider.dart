import 'dart:async';

import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/providers.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'details_provider.g.dart';

/// Extended detail data including the entry's current tier.
class EntryDetailData {
  final Entry entry;
  final Subject? subject;
  final Tier? tier;

  const EntryDetailData({required this.entry, this.subject, this.tier});
}

/// Watches a single entry with its primary subject and current tier
/// for the detail page.
@riverpod
class EntryDetail extends _$EntryDetail {
  Timer? _debounce;

  @override
  Future<EntryDetailData?> build(int entryId) async {
    ref.onDispose(() => _debounce?.cancel());
    return _fetchDetail();
  }

  Future<EntryDetailData?> _fetchDetail() async {
    final db = ref.read(databaseProvider);
    final row = await (db.select(db.entries).join([
      innerJoin(
        db.subjects,
        db.subjects.subjectId.equalsExp(db.entries.primarySubjectId),
      ),
      innerJoin(db.tiers, db.tiers.id.equalsExp(db.entries.tierId)),
    ])..where(db.entries.id.equals(entryId))).getSingleOrNull();

    if (row == null) {
      return null;
    }
    return EntryDetailData(
      entry: row.readTable(db.entries),
      subject: row.readTableOrNull(db.subjects),
      tier: row.readTableOrNull(db.tiers),
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
