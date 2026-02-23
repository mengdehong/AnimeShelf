// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bangumi_subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BangumiSubjectImpl _$$BangumiSubjectImplFromJson(Map<String, dynamic> json) =>
    _$BangumiSubjectImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      nameCn: json['name_cn'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      airDate: json['air_date'] as String? ?? '',
      eps: (json['eps'] as num?)?.toInt() ?? 0,
      images: json['images'] == null
          ? null
          : BangumiImages.fromJson(json['images'] as Map<String, dynamic>),
      rating: json['rating'] == null
          ? null
          : BangumiRating.fromJson(json['rating'] as Map<String, dynamic>),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => BangumiTag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      infobox:
          (json['infobox'] as List<dynamic>?)
              ?.map(
                (e) => BangumiInfoboxItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$BangumiSubjectImplToJson(
  _$BangumiSubjectImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'name_cn': instance.nameCn,
  'summary': instance.summary,
  'air_date': instance.airDate,
  'eps': instance.eps,
  'images': instance.images,
  'rating': instance.rating,
  'tags': instance.tags,
  'infobox': instance.infobox,
};

_$BangumiImagesImpl _$$BangumiImagesImplFromJson(Map<String, dynamic> json) =>
    _$BangumiImagesImpl(
      large: json['large'] as String? ?? '',
      medium: json['medium'] as String? ?? '',
      small: json['small'] as String? ?? '',
      grid: json['grid'] as String? ?? '',
    );

Map<String, dynamic> _$$BangumiImagesImplToJson(_$BangumiImagesImpl instance) =>
    <String, dynamic>{
      'large': instance.large,
      'medium': instance.medium,
      'small': instance.small,
      'grid': instance.grid,
    };

_$BangumiRatingImpl _$$BangumiRatingImplFromJson(Map<String, dynamic> json) =>
    _$BangumiRatingImpl(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BangumiRatingImplToJson(_$BangumiRatingImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
      'total': instance.total,
      'rank': instance.rank,
    };

_$BangumiTagImpl _$$BangumiTagImplFromJson(Map<String, dynamic> json) =>
    _$BangumiTagImpl(
      name: json['name'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BangumiTagImplToJson(_$BangumiTagImpl instance) =>
    <String, dynamic>{'name': instance.name, 'count': instance.count};

_$BangumiInfoboxItemImpl _$$BangumiInfoboxItemImplFromJson(
  Map<String, dynamic> json,
) => _$BangumiInfoboxItemImpl(
  key: json['key'] as String? ?? '',
  value: json['value'] == null ? '' : _infoboxValueFromJson(json['value']),
);

Map<String, dynamic> _$$BangumiInfoboxItemImplToJson(
  _$BangumiInfoboxItemImpl instance,
) => <String, dynamic>{'key': instance.key, 'value': instance.value};

_$BangumiSearchResponseImpl _$$BangumiSearchResponseImplFromJson(
  Map<String, dynamic> json,
) => _$BangumiSearchResponseImpl(
  total: (json['total'] as num?)?.toInt() ?? 0,
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => BangumiSubject.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$BangumiSearchResponseImplToJson(
  _$BangumiSearchResponseImpl instance,
) => <String, dynamic>{'total': instance.total, 'data': instance.data};
