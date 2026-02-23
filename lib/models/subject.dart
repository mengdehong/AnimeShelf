import 'package:drift/drift.dart';

/// Subject table — local snapshot of a Bangumi subject (anime).
///
/// Caches metadata fetched from the Bangumi API so the app can
/// display entries offline and avoid redundant network requests.
///
/// Image strategy:
/// - [posterUrl]: Bangumi medium-size URL (shelf network fallback).
/// - [largePosterUrl]: Bangumi large-size URL (detail network fallback).
/// - [localThumbnailPath]: device-local compressed thumbnail (shelf).
/// - [localLargeImagePath]: device-local full-size image (details).
///
/// Extended metadata (v5):
/// - [tags]: comma-separated top tags from Bangumi (e.g. "科幻,中二病,悬疑").
/// - [director]: director / 导演 / 监督, extracted from infobox.
/// - [studio]: animation studio / 动画制作, extracted from infobox.
/// - [globalRank]: Bangumi global ranking position (0 = unranked).
class Subjects extends Table {
  IntColumn get subjectId => integer()();
  TextColumn get nameCn => text().withDefault(const Constant(''))();
  TextColumn get nameJp => text().withDefault(const Constant(''))();
  TextColumn get posterUrl => text().withDefault(const Constant(''))();
  TextColumn get largePosterUrl => text().withDefault(const Constant(''))();
  TextColumn get localThumbnailPath => text().withDefault(const Constant(''))();
  TextColumn get localLargeImagePath =>
      text().withDefault(const Constant(''))();
  TextColumn get airDate => text().withDefault(const Constant(''))();
  IntColumn get eps => integer().withDefault(const Constant(0))();
  RealColumn get rating => real().withDefault(const Constant(0.0))();
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get tags => text().withDefault(const Constant(''))();
  TextColumn get director => text().withDefault(const Constant(''))();
  TextColumn get studio => text().withDefault(const Constant(''))();
  IntColumn get globalRank => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastFetchedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {subjectId};
}
