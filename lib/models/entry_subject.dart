import 'package:anime_shelf/models/entry.dart';
import 'package:anime_shelf/models/subject.dart';
import 'package:drift/drift.dart';

/// Junction table linking [Entries] to [Subjects] (many-to-many).
///
/// Enables season grouping: one entry can contain multiple seasons,
/// and this table tracks which subjects belong to which entry.
class EntrySubjects extends Table {
  IntColumn get entryId => integer().references(Entries, #id)();
  IntColumn get subjectId => integer().references(Subjects, #subjectId)();

  @override
  Set<Column> get primaryKey => {entryId, subjectId};
}
