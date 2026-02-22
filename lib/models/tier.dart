import 'package:drift/drift.dart';

/// Tier (等级) table — represents a ranking tier on the shelf.
///
/// Each tier has a name, optional emoji, color, and a sort value
/// for ordering tiers vertically on the shelf.
class Tiers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get emoji =>
      text().withLength(max: 10).withDefault(const Constant(''))();
  IntColumn get colorValue => integer()();
  RealColumn get tierSort => real()();
  BoolColumn get isInbox => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
