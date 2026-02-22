import 'package:drift/drift.dart';

/// Subject table — local snapshot of a Bangumi subject (anime).
///
/// Caches metadata fetched from the Bangumi API so the app can
/// display entries offline and avoid redundant network requests.
class Subjects extends Table {
  IntColumn get subjectId => integer()();
  TextColumn get nameCn => text().withDefault(const Constant(''))();
  TextColumn get nameJp => text().withDefault(const Constant(''))();
  TextColumn get posterUrl => text().withDefault(const Constant(''))();
  TextColumn get airDate => text().withDefault(const Constant(''))();
  IntColumn get eps => integer().withDefault(const Constant(0))();
  RealColumn get rating => real().withDefault(const Constant(0.0))();
  TextColumn get summary => text().withDefault(const Constant(''))();
  DateTimeColumn get lastFetchedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {subjectId};
}
