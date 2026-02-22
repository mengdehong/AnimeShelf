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
  }) = _BangumiRating;

  factory BangumiRating.fromJson(Map<String, dynamic> json) =>
      _$BangumiRatingFromJson(json);
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
