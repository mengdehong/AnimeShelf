// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bangumi_subject.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BangumiSubject _$BangumiSubjectFromJson(Map<String, dynamic> json) {
  return _BangumiSubject.fromJson(json);
}

/// @nodoc
mixin _$BangumiSubject {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_cn')
  String get nameCn => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  @JsonKey(name: 'air_date')
  String get airDate => throw _privateConstructorUsedError;
  int get eps => throw _privateConstructorUsedError;
  BangumiImages? get images => throw _privateConstructorUsedError;
  BangumiRating? get rating => throw _privateConstructorUsedError;

  /// Serializes this BangumiSubject to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BangumiSubject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BangumiSubjectCopyWith<BangumiSubject> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BangumiSubjectCopyWith<$Res> {
  factory $BangumiSubjectCopyWith(
    BangumiSubject value,
    $Res Function(BangumiSubject) then,
  ) = _$BangumiSubjectCopyWithImpl<$Res, BangumiSubject>;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'name_cn') String nameCn,
    String summary,
    @JsonKey(name: 'air_date') String airDate,
    int eps,
    BangumiImages? images,
    BangumiRating? rating,
  });

  $BangumiImagesCopyWith<$Res>? get images;
  $BangumiRatingCopyWith<$Res>? get rating;
}

/// @nodoc
class _$BangumiSubjectCopyWithImpl<$Res, $Val extends BangumiSubject>
    implements $BangumiSubjectCopyWith<$Res> {
  _$BangumiSubjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BangumiSubject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameCn = null,
    Object? summary = null,
    Object? airDate = null,
    Object? eps = null,
    Object? images = freezed,
    Object? rating = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            nameCn: null == nameCn
                ? _value.nameCn
                : nameCn // ignore: cast_nullable_to_non_nullable
                      as String,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as String,
            airDate: null == airDate
                ? _value.airDate
                : airDate // ignore: cast_nullable_to_non_nullable
                      as String,
            eps: null == eps
                ? _value.eps
                : eps // ignore: cast_nullable_to_non_nullable
                      as int,
            images: freezed == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as BangumiImages?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as BangumiRating?,
          )
          as $Val,
    );
  }

  /// Create a copy of BangumiSubject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BangumiImagesCopyWith<$Res>? get images {
    if (_value.images == null) {
      return null;
    }

    return $BangumiImagesCopyWith<$Res>(_value.images!, (value) {
      return _then(_value.copyWith(images: value) as $Val);
    });
  }

  /// Create a copy of BangumiSubject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BangumiRatingCopyWith<$Res>? get rating {
    if (_value.rating == null) {
      return null;
    }

    return $BangumiRatingCopyWith<$Res>(_value.rating!, (value) {
      return _then(_value.copyWith(rating: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BangumiSubjectImplCopyWith<$Res>
    implements $BangumiSubjectCopyWith<$Res> {
  factory _$$BangumiSubjectImplCopyWith(
    _$BangumiSubjectImpl value,
    $Res Function(_$BangumiSubjectImpl) then,
  ) = __$$BangumiSubjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'name_cn') String nameCn,
    String summary,
    @JsonKey(name: 'air_date') String airDate,
    int eps,
    BangumiImages? images,
    BangumiRating? rating,
  });

  @override
  $BangumiImagesCopyWith<$Res>? get images;
  @override
  $BangumiRatingCopyWith<$Res>? get rating;
}

/// @nodoc
class __$$BangumiSubjectImplCopyWithImpl<$Res>
    extends _$BangumiSubjectCopyWithImpl<$Res, _$BangumiSubjectImpl>
    implements _$$BangumiSubjectImplCopyWith<$Res> {
  __$$BangumiSubjectImplCopyWithImpl(
    _$BangumiSubjectImpl _value,
    $Res Function(_$BangumiSubjectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BangumiSubject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameCn = null,
    Object? summary = null,
    Object? airDate = null,
    Object? eps = null,
    Object? images = freezed,
    Object? rating = freezed,
  }) {
    return _then(
      _$BangumiSubjectImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        nameCn: null == nameCn
            ? _value.nameCn
            : nameCn // ignore: cast_nullable_to_non_nullable
                  as String,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as String,
        airDate: null == airDate
            ? _value.airDate
            : airDate // ignore: cast_nullable_to_non_nullable
                  as String,
        eps: null == eps
            ? _value.eps
            : eps // ignore: cast_nullable_to_non_nullable
                  as int,
        images: freezed == images
            ? _value.images
            : images // ignore: cast_nullable_to_non_nullable
                  as BangumiImages?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as BangumiRating?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BangumiSubjectImpl implements _BangumiSubject {
  const _$BangumiSubjectImpl({
    required this.id,
    this.name = '',
    @JsonKey(name: 'name_cn') this.nameCn = '',
    this.summary = '',
    @JsonKey(name: 'air_date') this.airDate = '',
    this.eps = 0,
    this.images,
    this.rating,
  });

  factory _$BangumiSubjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$BangumiSubjectImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey(name: 'name_cn')
  final String nameCn;
  @override
  @JsonKey()
  final String summary;
  @override
  @JsonKey(name: 'air_date')
  final String airDate;
  @override
  @JsonKey()
  final int eps;
  @override
  final BangumiImages? images;
  @override
  final BangumiRating? rating;

  @override
  String toString() {
    return 'BangumiSubject(id: $id, name: $name, nameCn: $nameCn, summary: $summary, airDate: $airDate, eps: $eps, images: $images, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BangumiSubjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameCn, nameCn) || other.nameCn == nameCn) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.airDate, airDate) || other.airDate == airDate) &&
            (identical(other.eps, eps) || other.eps == eps) &&
            (identical(other.images, images) || other.images == images) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    nameCn,
    summary,
    airDate,
    eps,
    images,
    rating,
  );

  /// Create a copy of BangumiSubject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BangumiSubjectImplCopyWith<_$BangumiSubjectImpl> get copyWith =>
      __$$BangumiSubjectImplCopyWithImpl<_$BangumiSubjectImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BangumiSubjectImplToJson(this);
  }
}

abstract class _BangumiSubject implements BangumiSubject {
  const factory _BangumiSubject({
    required final int id,
    final String name,
    @JsonKey(name: 'name_cn') final String nameCn,
    final String summary,
    @JsonKey(name: 'air_date') final String airDate,
    final int eps,
    final BangumiImages? images,
    final BangumiRating? rating,
  }) = _$BangumiSubjectImpl;

  factory _BangumiSubject.fromJson(Map<String, dynamic> json) =
      _$BangumiSubjectImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'name_cn')
  String get nameCn;
  @override
  String get summary;
  @override
  @JsonKey(name: 'air_date')
  String get airDate;
  @override
  int get eps;
  @override
  BangumiImages? get images;
  @override
  BangumiRating? get rating;

  /// Create a copy of BangumiSubject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BangumiSubjectImplCopyWith<_$BangumiSubjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BangumiImages _$BangumiImagesFromJson(Map<String, dynamic> json) {
  return _BangumiImages.fromJson(json);
}

/// @nodoc
mixin _$BangumiImages {
  String get large => throw _privateConstructorUsedError;
  String get medium => throw _privateConstructorUsedError;
  String get small => throw _privateConstructorUsedError;
  String get grid => throw _privateConstructorUsedError;

  /// Serializes this BangumiImages to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BangumiImages
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BangumiImagesCopyWith<BangumiImages> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BangumiImagesCopyWith<$Res> {
  factory $BangumiImagesCopyWith(
    BangumiImages value,
    $Res Function(BangumiImages) then,
  ) = _$BangumiImagesCopyWithImpl<$Res, BangumiImages>;
  @useResult
  $Res call({String large, String medium, String small, String grid});
}

/// @nodoc
class _$BangumiImagesCopyWithImpl<$Res, $Val extends BangumiImages>
    implements $BangumiImagesCopyWith<$Res> {
  _$BangumiImagesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BangumiImages
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? large = null,
    Object? medium = null,
    Object? small = null,
    Object? grid = null,
  }) {
    return _then(
      _value.copyWith(
            large: null == large
                ? _value.large
                : large // ignore: cast_nullable_to_non_nullable
                      as String,
            medium: null == medium
                ? _value.medium
                : medium // ignore: cast_nullable_to_non_nullable
                      as String,
            small: null == small
                ? _value.small
                : small // ignore: cast_nullable_to_non_nullable
                      as String,
            grid: null == grid
                ? _value.grid
                : grid // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BangumiImagesImplCopyWith<$Res>
    implements $BangumiImagesCopyWith<$Res> {
  factory _$$BangumiImagesImplCopyWith(
    _$BangumiImagesImpl value,
    $Res Function(_$BangumiImagesImpl) then,
  ) = __$$BangumiImagesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String large, String medium, String small, String grid});
}

/// @nodoc
class __$$BangumiImagesImplCopyWithImpl<$Res>
    extends _$BangumiImagesCopyWithImpl<$Res, _$BangumiImagesImpl>
    implements _$$BangumiImagesImplCopyWith<$Res> {
  __$$BangumiImagesImplCopyWithImpl(
    _$BangumiImagesImpl _value,
    $Res Function(_$BangumiImagesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BangumiImages
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? large = null,
    Object? medium = null,
    Object? small = null,
    Object? grid = null,
  }) {
    return _then(
      _$BangumiImagesImpl(
        large: null == large
            ? _value.large
            : large // ignore: cast_nullable_to_non_nullable
                  as String,
        medium: null == medium
            ? _value.medium
            : medium // ignore: cast_nullable_to_non_nullable
                  as String,
        small: null == small
            ? _value.small
            : small // ignore: cast_nullable_to_non_nullable
                  as String,
        grid: null == grid
            ? _value.grid
            : grid // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BangumiImagesImpl implements _BangumiImages {
  const _$BangumiImagesImpl({
    this.large = '',
    this.medium = '',
    this.small = '',
    this.grid = '',
  });

  factory _$BangumiImagesImpl.fromJson(Map<String, dynamic> json) =>
      _$$BangumiImagesImplFromJson(json);

  @override
  @JsonKey()
  final String large;
  @override
  @JsonKey()
  final String medium;
  @override
  @JsonKey()
  final String small;
  @override
  @JsonKey()
  final String grid;

  @override
  String toString() {
    return 'BangumiImages(large: $large, medium: $medium, small: $small, grid: $grid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BangumiImagesImpl &&
            (identical(other.large, large) || other.large == large) &&
            (identical(other.medium, medium) || other.medium == medium) &&
            (identical(other.small, small) || other.small == small) &&
            (identical(other.grid, grid) || other.grid == grid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, large, medium, small, grid);

  /// Create a copy of BangumiImages
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BangumiImagesImplCopyWith<_$BangumiImagesImpl> get copyWith =>
      __$$BangumiImagesImplCopyWithImpl<_$BangumiImagesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BangumiImagesImplToJson(this);
  }
}

abstract class _BangumiImages implements BangumiImages {
  const factory _BangumiImages({
    final String large,
    final String medium,
    final String small,
    final String grid,
  }) = _$BangumiImagesImpl;

  factory _BangumiImages.fromJson(Map<String, dynamic> json) =
      _$BangumiImagesImpl.fromJson;

  @override
  String get large;
  @override
  String get medium;
  @override
  String get small;
  @override
  String get grid;

  /// Create a copy of BangumiImages
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BangumiImagesImplCopyWith<_$BangumiImagesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BangumiRating _$BangumiRatingFromJson(Map<String, dynamic> json) {
  return _BangumiRating.fromJson(json);
}

/// @nodoc
mixin _$BangumiRating {
  double get score => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this BangumiRating to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BangumiRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BangumiRatingCopyWith<BangumiRating> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BangumiRatingCopyWith<$Res> {
  factory $BangumiRatingCopyWith(
    BangumiRating value,
    $Res Function(BangumiRating) then,
  ) = _$BangumiRatingCopyWithImpl<$Res, BangumiRating>;
  @useResult
  $Res call({double score, int total});
}

/// @nodoc
class _$BangumiRatingCopyWithImpl<$Res, $Val extends BangumiRating>
    implements $BangumiRatingCopyWith<$Res> {
  _$BangumiRatingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BangumiRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? score = null, Object? total = null}) {
    return _then(
      _value.copyWith(
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BangumiRatingImplCopyWith<$Res>
    implements $BangumiRatingCopyWith<$Res> {
  factory _$$BangumiRatingImplCopyWith(
    _$BangumiRatingImpl value,
    $Res Function(_$BangumiRatingImpl) then,
  ) = __$$BangumiRatingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double score, int total});
}

/// @nodoc
class __$$BangumiRatingImplCopyWithImpl<$Res>
    extends _$BangumiRatingCopyWithImpl<$Res, _$BangumiRatingImpl>
    implements _$$BangumiRatingImplCopyWith<$Res> {
  __$$BangumiRatingImplCopyWithImpl(
    _$BangumiRatingImpl _value,
    $Res Function(_$BangumiRatingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BangumiRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? score = null, Object? total = null}) {
    return _then(
      _$BangumiRatingImpl(
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BangumiRatingImpl implements _BangumiRating {
  const _$BangumiRatingImpl({this.score = 0.0, this.total = 0});

  factory _$BangumiRatingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BangumiRatingImplFromJson(json);

  @override
  @JsonKey()
  final double score;
  @override
  @JsonKey()
  final int total;

  @override
  String toString() {
    return 'BangumiRating(score: $score, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BangumiRatingImpl &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, score, total);

  /// Create a copy of BangumiRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BangumiRatingImplCopyWith<_$BangumiRatingImpl> get copyWith =>
      __$$BangumiRatingImplCopyWithImpl<_$BangumiRatingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BangumiRatingImplToJson(this);
  }
}

abstract class _BangumiRating implements BangumiRating {
  const factory _BangumiRating({final double score, final int total}) =
      _$BangumiRatingImpl;

  factory _BangumiRating.fromJson(Map<String, dynamic> json) =
      _$BangumiRatingImpl.fromJson;

  @override
  double get score;
  @override
  int get total;

  /// Create a copy of BangumiRating
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BangumiRatingImplCopyWith<_$BangumiRatingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BangumiSearchResponse _$BangumiSearchResponseFromJson(
  Map<String, dynamic> json,
) {
  return _BangumiSearchResponse.fromJson(json);
}

/// @nodoc
mixin _$BangumiSearchResponse {
  int get total => throw _privateConstructorUsedError;
  List<BangumiSubject> get data => throw _privateConstructorUsedError;

  /// Serializes this BangumiSearchResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BangumiSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BangumiSearchResponseCopyWith<BangumiSearchResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BangumiSearchResponseCopyWith<$Res> {
  factory $BangumiSearchResponseCopyWith(
    BangumiSearchResponse value,
    $Res Function(BangumiSearchResponse) then,
  ) = _$BangumiSearchResponseCopyWithImpl<$Res, BangumiSearchResponse>;
  @useResult
  $Res call({int total, List<BangumiSubject> data});
}

/// @nodoc
class _$BangumiSearchResponseCopyWithImpl<
  $Res,
  $Val extends BangumiSearchResponse
>
    implements $BangumiSearchResponseCopyWith<$Res> {
  _$BangumiSearchResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BangumiSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? total = null, Object? data = null}) {
    return _then(
      _value.copyWith(
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<BangumiSubject>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BangumiSearchResponseImplCopyWith<$Res>
    implements $BangumiSearchResponseCopyWith<$Res> {
  factory _$$BangumiSearchResponseImplCopyWith(
    _$BangumiSearchResponseImpl value,
    $Res Function(_$BangumiSearchResponseImpl) then,
  ) = __$$BangumiSearchResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int total, List<BangumiSubject> data});
}

/// @nodoc
class __$$BangumiSearchResponseImplCopyWithImpl<$Res>
    extends
        _$BangumiSearchResponseCopyWithImpl<$Res, _$BangumiSearchResponseImpl>
    implements _$$BangumiSearchResponseImplCopyWith<$Res> {
  __$$BangumiSearchResponseImplCopyWithImpl(
    _$BangumiSearchResponseImpl _value,
    $Res Function(_$BangumiSearchResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BangumiSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? total = null, Object? data = null}) {
    return _then(
      _$BangumiSearchResponseImpl(
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<BangumiSubject>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BangumiSearchResponseImpl implements _BangumiSearchResponse {
  const _$BangumiSearchResponseImpl({
    this.total = 0,
    final List<BangumiSubject> data = const [],
  }) : _data = data;

  factory _$BangumiSearchResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BangumiSearchResponseImplFromJson(json);

  @override
  @JsonKey()
  final int total;
  final List<BangumiSubject> _data;
  @override
  @JsonKey()
  List<BangumiSubject> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'BangumiSearchResponse(total: $total, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BangumiSearchResponseImpl &&
            (identical(other.total, total) || other.total == total) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    total,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of BangumiSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BangumiSearchResponseImplCopyWith<_$BangumiSearchResponseImpl>
  get copyWith =>
      __$$BangumiSearchResponseImplCopyWithImpl<_$BangumiSearchResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BangumiSearchResponseImplToJson(this);
  }
}

abstract class _BangumiSearchResponse implements BangumiSearchResponse {
  const factory _BangumiSearchResponse({
    final int total,
    final List<BangumiSubject> data,
  }) = _$BangumiSearchResponseImpl;

  factory _BangumiSearchResponse.fromJson(Map<String, dynamic> json) =
      _$BangumiSearchResponseImpl.fromJson;

  @override
  int get total;
  @override
  List<BangumiSubject> get data;

  /// Create a copy of BangumiSearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BangumiSearchResponseImplCopyWith<_$BangumiSearchResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
