import 'package:freezed_annotation/freezed_annotation.dart';

part 'bangumi_subject.freezed.dart';
part 'bangumi_subject.g.dart';

/// Bangumi API subject model — represents a single anime entry
/// as returned by the Bangumi v0 search/subject endpoints.
@freezed
class BangumiSubject with _$BangumiSubject {
  const factory BangumiSubject({
    required int id,
    @Default('') String name,
    @JsonKey(name: 'name_cn') @Default('') String nameCn,
    @Default('') String summary,
    @JsonKey(name: 'air_date') @Default('') String airDate,
    @Default(0) int eps,
    BangumiImages? images,
    BangumiRating? rating,
    @Default([]) List<BangumiTag> tags,
    @Default([]) List<BangumiInfoboxItem> infobox,
  }) = _BangumiSubject;

  factory BangumiSubject.fromJson(Map<String, dynamic> json) =>
      _$BangumiSubjectFromJson(json);
}

@freezed
class BangumiImages with _$BangumiImages {
  const factory BangumiImages({
    @Default('') String large,
    @Default('') String medium,
    @Default('') String small,
    @Default('') String grid,
  }) = _BangumiImages;

  factory BangumiImages.fromJson(Map<String, dynamic> json) =>
      _$BangumiImagesFromJson(json);
}

@freezed
class BangumiRating with _$BangumiRating {
  const factory BangumiRating({
    @Default(0.0) double score,
    @Default(0) int total,
    @Default(0) int rank,
  }) = _BangumiRating;

  factory BangumiRating.fromJson(Map<String, dynamic> json) =>
      _$BangumiRatingFromJson(json);
}

/// A single tag from the Bangumi API with its usage count.
@freezed
class BangumiTag with _$BangumiTag {
  const factory BangumiTag({@Default('') String name, @Default(0) int count}) =
      _BangumiTag;

  factory BangumiTag.fromJson(Map<String, dynamic> json) =>
      _$BangumiTagFromJson(json);
}

/// A single key-value item from the Bangumi infobox array.
///
/// The `value` field in the API can be either a plain string or a
/// list of objects; we normalise it to a single string at parse time.
@freezed
class BangumiInfoboxItem with _$BangumiInfoboxItem {
  const factory BangumiInfoboxItem({
    @Default('') String key,
    @Default('') @JsonKey(fromJson: _infoboxValueFromJson) String value,
  }) = _BangumiInfoboxItem;

  factory BangumiInfoboxItem.fromJson(Map<String, dynamic> json) =>
      _$BangumiInfoboxItemFromJson(json);
}

/// Normalises the polymorphic infobox `value` field.
///
/// Bangumi returns either a plain string or a list of `{"v": "..."}` maps.
String _infoboxValueFromJson(dynamic json) {
  if (json is String) {
    return json;
  }
  if (json is List) {
    return json
        .whereType<Map<String, dynamic>>()
        .map((item) => item['v']?.toString() ?? '')
        .where((v) => v.isNotEmpty)
        .join(', ');
  }
  return json?.toString() ?? '';
}

/// Bangumi search API response wrapper.
@freezed
class BangumiSearchResponse with _$BangumiSearchResponse {
  const factory BangumiSearchResponse({
    @Default(0) int total,
    @Default([]) List<BangumiSubject> data,
  }) = _BangumiSearchResponse;

  factory BangumiSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$BangumiSearchResponseFromJson(json);
}
