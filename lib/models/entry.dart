import 'package:anime_shelf/models/subject.dart';
import 'package:anime_shelf/models/tier.dart';
import 'package:drift/drift.dart';

/// Entry table — a card on the shelf representing one or more seasons.
///
/// Each entry belongs to a [Tier] and has a rank for ordering within
/// that tier. An entry may link to multiple [Subject]s via
/// [EntrySubjects], but always has a primary subject for display.
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tierId => integer().references(Tiers, #id)();
  IntColumn get primarySubjectId =>
      integer().references(Subjects, #subjectId)();
  RealColumn get entryRank => real()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
