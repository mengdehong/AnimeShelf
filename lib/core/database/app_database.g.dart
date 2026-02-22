// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TiersTable extends Tiers with TableInfo<$TiersTable, Tier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TiersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierSortMeta = const VerificationMeta(
    'tierSort',
  );
  @override
  late final GeneratedColumn<double> tierSort = GeneratedColumn<double>(
    'tier_sort',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isInboxMeta = const VerificationMeta(
    'isInbox',
  );
  @override
  late final GeneratedColumn<bool> isInbox = GeneratedColumn<bool>(
    'is_inbox',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_inbox" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    emoji,
    colorValue,
    tierSort,
    isInbox,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tiers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('tier_sort')) {
      context.handle(
        _tierSortMeta,
        tierSort.isAcceptableOrUnknown(data['tier_sort']!, _tierSortMeta),
      );
    } else if (isInserting) {
      context.missing(_tierSortMeta);
    }
    if (data.containsKey('is_inbox')) {
      context.handle(
        _isInboxMeta,
        isInbox.isAcceptableOrUnknown(data['is_inbox']!, _isInboxMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      tierSort: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tier_sort'],
      )!,
      isInbox: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_inbox'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TiersTable createAlias(String alias) {
    return $TiersTable(attachedDatabase, alias);
  }
}

class Tier extends DataClass implements Insertable<Tier> {
  final int id;
  final String name;
  final String emoji;
  final int colorValue;
  final double tierSort;
  final bool isInbox;
  final DateTime createdAt;
  const Tier({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
    required this.tierSort,
    required this.isInbox,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color_value'] = Variable<int>(colorValue);
    map['tier_sort'] = Variable<double>(tierSort);
    map['is_inbox'] = Variable<bool>(isInbox);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TiersCompanion toCompanion(bool nullToAbsent) {
    return TiersCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      colorValue: Value(colorValue),
      tierSort: Value(tierSort),
      isInbox: Value(isInbox),
      createdAt: Value(createdAt),
    );
  }

  factory Tier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tier(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      tierSort: serializer.fromJson<double>(json['tierSort']),
      isInbox: serializer.fromJson<bool>(json['isInbox']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'colorValue': serializer.toJson<int>(colorValue),
      'tierSort': serializer.toJson<double>(tierSort),
      'isInbox': serializer.toJson<bool>(isInbox),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Tier copyWith({
    int? id,
    String? name,
    String? emoji,
    int? colorValue,
    double? tierSort,
    bool? isInbox,
    DateTime? createdAt,
  }) => Tier(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    colorValue: colorValue ?? this.colorValue,
    tierSort: tierSort ?? this.tierSort,
    isInbox: isInbox ?? this.isInbox,
    createdAt: createdAt ?? this.createdAt,
  );
  Tier copyWithCompanion(TiersCompanion data) {
    return Tier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      tierSort: data.tierSort.present ? data.tierSort.value : this.tierSort,
      isInbox: data.isInbox.present ? data.isInbox.value : this.isInbox,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('colorValue: $colorValue, ')
          ..write('tierSort: $tierSort, ')
          ..write('isInbox: $isInbox, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, emoji, colorValue, tierSort, isInbox, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tier &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.colorValue == this.colorValue &&
          other.tierSort == this.tierSort &&
          other.isInbox == this.isInbox &&
          other.createdAt == this.createdAt);
}

class TiersCompanion extends UpdateCompanion<Tier> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> colorValue;
  final Value<double> tierSort;
  final Value<bool> isInbox;
  final Value<DateTime> createdAt;
  const TiersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.tierSort = const Value.absent(),
    this.isInbox = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TiersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.emoji = const Value.absent(),
    required int colorValue,
    required double tierSort,
    this.isInbox = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       colorValue = Value(colorValue),
       tierSort = Value(tierSort);
  static Insertable<Tier> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? colorValue,
    Expression<double>? tierSort,
    Expression<bool>? isInbox,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (colorValue != null) 'color_value': colorValue,
      if (tierSort != null) 'tier_sort': tierSort,
      if (isInbox != null) 'is_inbox': isInbox,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TiersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<int>? colorValue,
    Value<double>? tierSort,
    Value<bool>? isInbox,
    Value<DateTime>? createdAt,
  }) {
    return TiersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      tierSort: tierSort ?? this.tierSort,
      isInbox: isInbox ?? this.isInbox,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (tierSort.present) {
      map['tier_sort'] = Variable<double>(tierSort.value);
    }
    if (isInbox.present) {
      map['is_inbox'] = Variable<bool>(isInbox.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TiersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('colorValue: $colorValue, ')
          ..write('tierSort: $tierSort, ')
          ..write('isInbox: $isInbox, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameCnMeta = const VerificationMeta('nameCn');
  @override
  late final GeneratedColumn<String> nameCn = GeneratedColumn<String>(
    'name_cn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nameJpMeta = const VerificationMeta('nameJp');
  @override
  late final GeneratedColumn<String> nameJp = GeneratedColumn<String>(
    'name_jp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _posterUrlMeta = const VerificationMeta(
    'posterUrl',
  );
  @override
  late final GeneratedColumn<String> posterUrl = GeneratedColumn<String>(
    'poster_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _airDateMeta = const VerificationMeta(
    'airDate',
  );
  @override
  late final GeneratedColumn<String> airDate = GeneratedColumn<String>(
    'air_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _epsMeta = const VerificationMeta('eps');
  @override
  late final GeneratedColumn<int> eps = GeneratedColumn<int>(
    'eps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastFetchedAtMeta = const VerificationMeta(
    'lastFetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetchedAt =
      GeneratedColumn<DateTime>(
        'last_fetched_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    subjectId,
    nameCn,
    nameJp,
    posterUrl,
    airDate,
    eps,
    rating,
    summary,
    lastFetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('name_cn')) {
      context.handle(
        _nameCnMeta,
        nameCn.isAcceptableOrUnknown(data['name_cn']!, _nameCnMeta),
      );
    }
    if (data.containsKey('name_jp')) {
      context.handle(
        _nameJpMeta,
        nameJp.isAcceptableOrUnknown(data['name_jp']!, _nameJpMeta),
      );
    }
    if (data.containsKey('poster_url')) {
      context.handle(
        _posterUrlMeta,
        posterUrl.isAcceptableOrUnknown(data['poster_url']!, _posterUrlMeta),
      );
    }
    if (data.containsKey('air_date')) {
      context.handle(
        _airDateMeta,
        airDate.isAcceptableOrUnknown(data['air_date']!, _airDateMeta),
      );
    }
    if (data.containsKey('eps')) {
      context.handle(
        _epsMeta,
        eps.isAcceptableOrUnknown(data['eps']!, _epsMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('last_fetched_at')) {
      context.handle(
        _lastFetchedAtMeta,
        lastFetchedAt.isAcceptableOrUnknown(
          data['last_fetched_at']!,
          _lastFetchedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {subjectId};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      )!,
      nameCn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_cn'],
      )!,
      nameJp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_jp'],
      )!,
      posterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_url'],
      )!,
      airDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}air_date'],
      )!,
      eps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eps'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      lastFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched_at'],
      )!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int subjectId;
  final String nameCn;
  final String nameJp;
  final String posterUrl;
  final String airDate;
  final int eps;
  final double rating;
  final String summary;
  final DateTime lastFetchedAt;
  const Subject({
    required this.subjectId,
    required this.nameCn,
    required this.nameJp,
    required this.posterUrl,
    required this.airDate,
    required this.eps,
    required this.rating,
    required this.summary,
    required this.lastFetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['subject_id'] = Variable<int>(subjectId);
    map['name_cn'] = Variable<String>(nameCn);
    map['name_jp'] = Variable<String>(nameJp);
    map['poster_url'] = Variable<String>(posterUrl);
    map['air_date'] = Variable<String>(airDate);
    map['eps'] = Variable<int>(eps);
    map['rating'] = Variable<double>(rating);
    map['summary'] = Variable<String>(summary);
    map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      subjectId: Value(subjectId),
      nameCn: Value(nameCn),
      nameJp: Value(nameJp),
      posterUrl: Value(posterUrl),
      airDate: Value(airDate),
      eps: Value(eps),
      rating: Value(rating),
      summary: Value(summary),
      lastFetchedAt: Value(lastFetchedAt),
    );
  }

  factory Subject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      subjectId: serializer.fromJson<int>(json['subjectId']),
      nameCn: serializer.fromJson<String>(json['nameCn']),
      nameJp: serializer.fromJson<String>(json['nameJp']),
      posterUrl: serializer.fromJson<String>(json['posterUrl']),
      airDate: serializer.fromJson<String>(json['airDate']),
      eps: serializer.fromJson<int>(json['eps']),
      rating: serializer.fromJson<double>(json['rating']),
      summary: serializer.fromJson<String>(json['summary']),
      lastFetchedAt: serializer.fromJson<DateTime>(json['lastFetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'subjectId': serializer.toJson<int>(subjectId),
      'nameCn': serializer.toJson<String>(nameCn),
      'nameJp': serializer.toJson<String>(nameJp),
      'posterUrl': serializer.toJson<String>(posterUrl),
      'airDate': serializer.toJson<String>(airDate),
      'eps': serializer.toJson<int>(eps),
      'rating': serializer.toJson<double>(rating),
      'summary': serializer.toJson<String>(summary),
      'lastFetchedAt': serializer.toJson<DateTime>(lastFetchedAt),
    };
  }

  Subject copyWith({
    int? subjectId,
    String? nameCn,
    String? nameJp,
    String? posterUrl,
    String? airDate,
    int? eps,
    double? rating,
    String? summary,
    DateTime? lastFetchedAt,
  }) => Subject(
    subjectId: subjectId ?? this.subjectId,
    nameCn: nameCn ?? this.nameCn,
    nameJp: nameJp ?? this.nameJp,
    posterUrl: posterUrl ?? this.posterUrl,
    airDate: airDate ?? this.airDate,
    eps: eps ?? this.eps,
    rating: rating ?? this.rating,
    summary: summary ?? this.summary,
    lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
  );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      nameCn: data.nameCn.present ? data.nameCn.value : this.nameCn,
      nameJp: data.nameJp.present ? data.nameJp.value : this.nameJp,
      posterUrl: data.posterUrl.present ? data.posterUrl.value : this.posterUrl,
      airDate: data.airDate.present ? data.airDate.value : this.airDate,
      eps: data.eps.present ? data.eps.value : this.eps,
      rating: data.rating.present ? data.rating.value : this.rating,
      summary: data.summary.present ? data.summary.value : this.summary,
      lastFetchedAt: data.lastFetchedAt.present
          ? data.lastFetchedAt.value
          : this.lastFetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('subjectId: $subjectId, ')
          ..write('nameCn: $nameCn, ')
          ..write('nameJp: $nameJp, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('airDate: $airDate, ')
          ..write('eps: $eps, ')
          ..write('rating: $rating, ')
          ..write('summary: $summary, ')
          ..write('lastFetchedAt: $lastFetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    subjectId,
    nameCn,
    nameJp,
    posterUrl,
    airDate,
    eps,
    rating,
    summary,
    lastFetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.subjectId == this.subjectId &&
          other.nameCn == this.nameCn &&
          other.nameJp == this.nameJp &&
          other.posterUrl == this.posterUrl &&
          other.airDate == this.airDate &&
          other.eps == this.eps &&
          other.rating == this.rating &&
          other.summary == this.summary &&
          other.lastFetchedAt == this.lastFetchedAt);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> subjectId;
  final Value<String> nameCn;
  final Value<String> nameJp;
  final Value<String> posterUrl;
  final Value<String> airDate;
  final Value<int> eps;
  final Value<double> rating;
  final Value<String> summary;
  final Value<DateTime> lastFetchedAt;
  const SubjectsCompanion({
    this.subjectId = const Value.absent(),
    this.nameCn = const Value.absent(),
    this.nameJp = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.airDate = const Value.absent(),
    this.eps = const Value.absent(),
    this.rating = const Value.absent(),
    this.summary = const Value.absent(),
    this.lastFetchedAt = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.subjectId = const Value.absent(),
    this.nameCn = const Value.absent(),
    this.nameJp = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.airDate = const Value.absent(),
    this.eps = const Value.absent(),
    this.rating = const Value.absent(),
    this.summary = const Value.absent(),
    this.lastFetchedAt = const Value.absent(),
  });
  static Insertable<Subject> custom({
    Expression<int>? subjectId,
    Expression<String>? nameCn,
    Expression<String>? nameJp,
    Expression<String>? posterUrl,
    Expression<String>? airDate,
    Expression<int>? eps,
    Expression<double>? rating,
    Expression<String>? summary,
    Expression<DateTime>? lastFetchedAt,
  }) {
    return RawValuesInsertable({
      if (subjectId != null) 'subject_id': subjectId,
      if (nameCn != null) 'name_cn': nameCn,
      if (nameJp != null) 'name_jp': nameJp,
      if (posterUrl != null) 'poster_url': posterUrl,
      if (airDate != null) 'air_date': airDate,
      if (eps != null) 'eps': eps,
      if (rating != null) 'rating': rating,
      if (summary != null) 'summary': summary,
      if (lastFetchedAt != null) 'last_fetched_at': lastFetchedAt,
    });
  }

  SubjectsCompanion copyWith({
    Value<int>? subjectId,
    Value<String>? nameCn,
    Value<String>? nameJp,
    Value<String>? posterUrl,
    Value<String>? airDate,
    Value<int>? eps,
    Value<double>? rating,
    Value<String>? summary,
    Value<DateTime>? lastFetchedAt,
  }) {
    return SubjectsCompanion(
      subjectId: subjectId ?? this.subjectId,
      nameCn: nameCn ?? this.nameCn,
      nameJp: nameJp ?? this.nameJp,
      posterUrl: posterUrl ?? this.posterUrl,
      airDate: airDate ?? this.airDate,
      eps: eps ?? this.eps,
      rating: rating ?? this.rating,
      summary: summary ?? this.summary,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (nameCn.present) {
      map['name_cn'] = Variable<String>(nameCn.value);
    }
    if (nameJp.present) {
      map['name_jp'] = Variable<String>(nameJp.value);
    }
    if (posterUrl.present) {
      map['poster_url'] = Variable<String>(posterUrl.value);
    }
    if (airDate.present) {
      map['air_date'] = Variable<String>(airDate.value);
    }
    if (eps.present) {
      map['eps'] = Variable<int>(eps.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (lastFetchedAt.present) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('subjectId: $subjectId, ')
          ..write('nameCn: $nameCn, ')
          ..write('nameJp: $nameJp, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('airDate: $airDate, ')
          ..write('eps: $eps, ')
          ..write('rating: $rating, ')
          ..write('summary: $summary, ')
          ..write('lastFetchedAt: $lastFetchedAt')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tierIdMeta = const VerificationMeta('tierId');
  @override
  late final GeneratedColumn<int> tierId = GeneratedColumn<int>(
    'tier_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tiers (id)',
    ),
  );
  static const VerificationMeta _primarySubjectIdMeta = const VerificationMeta(
    'primarySubjectId',
  );
  @override
  late final GeneratedColumn<int> primarySubjectId = GeneratedColumn<int>(
    'primary_subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (subject_id)',
    ),
  );
  static const VerificationMeta _entryRankMeta = const VerificationMeta(
    'entryRank',
  );
  @override
  late final GeneratedColumn<double> entryRank = GeneratedColumn<double>(
    'entry_rank',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tierId,
    primarySubjectId,
    entryRank,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tier_id')) {
      context.handle(
        _tierIdMeta,
        tierId.isAcceptableOrUnknown(data['tier_id']!, _tierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tierIdMeta);
    }
    if (data.containsKey('primary_subject_id')) {
      context.handle(
        _primarySubjectIdMeta,
        primarySubjectId.isAcceptableOrUnknown(
          data['primary_subject_id']!,
          _primarySubjectIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primarySubjectIdMeta);
    }
    if (data.containsKey('entry_rank')) {
      context.handle(
        _entryRankMeta,
        entryRank.isAcceptableOrUnknown(data['entry_rank']!, _entryRankMeta),
      );
    } else if (isInserting) {
      context.missing(_entryRankMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tierId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tier_id'],
      )!,
      primarySubjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}primary_subject_id'],
      )!,
      entryRank: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}entry_rank'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  final int id;
  final int tierId;
  final int primarySubjectId;
  final double entryRank;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Entry({
    required this.id,
    required this.tierId,
    required this.primarySubjectId,
    required this.entryRank,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tier_id'] = Variable<int>(tierId);
    map['primary_subject_id'] = Variable<int>(primarySubjectId);
    map['entry_rank'] = Variable<double>(entryRank);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      tierId: Value(tierId),
      primarySubjectId: Value(primarySubjectId),
      entryRank: Value(entryRank),
      note: Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<int>(json['id']),
      tierId: serializer.fromJson<int>(json['tierId']),
      primarySubjectId: serializer.fromJson<int>(json['primarySubjectId']),
      entryRank: serializer.fromJson<double>(json['entryRank']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tierId': serializer.toJson<int>(tierId),
      'primarySubjectId': serializer.toJson<int>(primarySubjectId),
      'entryRank': serializer.toJson<double>(entryRank),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Entry copyWith({
    int? id,
    int? tierId,
    int? primarySubjectId,
    double? entryRank,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Entry(
    id: id ?? this.id,
    tierId: tierId ?? this.tierId,
    primarySubjectId: primarySubjectId ?? this.primarySubjectId,
    entryRank: entryRank ?? this.entryRank,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      tierId: data.tierId.present ? data.tierId.value : this.tierId,
      primarySubjectId: data.primarySubjectId.present
          ? data.primarySubjectId.value
          : this.primarySubjectId,
      entryRank: data.entryRank.present ? data.entryRank.value : this.entryRank,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('tierId: $tierId, ')
          ..write('primarySubjectId: $primarySubjectId, ')
          ..write('entryRank: $entryRank, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tierId,
    primarySubjectId,
    entryRank,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.tierId == this.tierId &&
          other.primarySubjectId == this.primarySubjectId &&
          other.entryRank == this.entryRank &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<int> id;
  final Value<int> tierId;
  final Value<int> primarySubjectId;
  final Value<double> entryRank;
  final Value<String> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.tierId = const Value.absent(),
    this.primarySubjectId = const Value.absent(),
    this.entryRank = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required int tierId,
    required int primarySubjectId,
    required double entryRank,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : tierId = Value(tierId),
       primarySubjectId = Value(primarySubjectId),
       entryRank = Value(entryRank);
  static Insertable<Entry> custom({
    Expression<int>? id,
    Expression<int>? tierId,
    Expression<int>? primarySubjectId,
    Expression<double>? entryRank,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tierId != null) 'tier_id': tierId,
      if (primarySubjectId != null) 'primary_subject_id': primarySubjectId,
      if (entryRank != null) 'entry_rank': entryRank,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? tierId,
    Value<int>? primarySubjectId,
    Value<double>? entryRank,
    Value<String>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      tierId: tierId ?? this.tierId,
      primarySubjectId: primarySubjectId ?? this.primarySubjectId,
      entryRank: entryRank ?? this.entryRank,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tierId.present) {
      map['tier_id'] = Variable<int>(tierId.value);
    }
    if (primarySubjectId.present) {
      map['primary_subject_id'] = Variable<int>(primarySubjectId.value);
    }
    if (entryRank.present) {
      map['entry_rank'] = Variable<double>(entryRank.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('tierId: $tierId, ')
          ..write('primarySubjectId: $primarySubjectId, ')
          ..write('entryRank: $entryRank, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EntrySubjectsTable extends EntrySubjects
    with TableInfo<$EntrySubjectsTable, EntrySubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntrySubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES entries (id)',
    ),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (subject_id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [entryId, subjectId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntrySubject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId, subjectId};
  @override
  EntrySubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntrySubject(
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      )!,
    );
  }

  @override
  $EntrySubjectsTable createAlias(String alias) {
    return $EntrySubjectsTable(attachedDatabase, alias);
  }
}

class EntrySubject extends DataClass implements Insertable<EntrySubject> {
  final int entryId;
  final int subjectId;
  const EntrySubject({required this.entryId, required this.subjectId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<int>(entryId);
    map['subject_id'] = Variable<int>(subjectId);
    return map;
  }

  EntrySubjectsCompanion toCompanion(bool nullToAbsent) {
    return EntrySubjectsCompanion(
      entryId: Value(entryId),
      subjectId: Value(subjectId),
    );
  }

  factory EntrySubject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntrySubject(
      entryId: serializer.fromJson<int>(json['entryId']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<int>(entryId),
      'subjectId': serializer.toJson<int>(subjectId),
    };
  }

  EntrySubject copyWith({int? entryId, int? subjectId}) => EntrySubject(
    entryId: entryId ?? this.entryId,
    subjectId: subjectId ?? this.subjectId,
  );
  EntrySubject copyWithCompanion(EntrySubjectsCompanion data) {
    return EntrySubject(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntrySubject(')
          ..write('entryId: $entryId, ')
          ..write('subjectId: $subjectId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, subjectId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntrySubject &&
          other.entryId == this.entryId &&
          other.subjectId == this.subjectId);
}

class EntrySubjectsCompanion extends UpdateCompanion<EntrySubject> {
  final Value<int> entryId;
  final Value<int> subjectId;
  final Value<int> rowid;
  const EntrySubjectsCompanion({
    this.entryId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntrySubjectsCompanion.insert({
    required int entryId,
    required int subjectId,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       subjectId = Value(subjectId);
  static Insertable<EntrySubject> custom({
    Expression<int>? entryId,
    Expression<int>? subjectId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (subjectId != null) 'subject_id': subjectId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntrySubjectsCompanion copyWith({
    Value<int>? entryId,
    Value<int>? subjectId,
    Value<int>? rowid,
  }) {
    return EntrySubjectsCompanion(
      entryId: entryId ?? this.entryId,
      subjectId: subjectId ?? this.subjectId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntrySubjectsCompanion(')
          ..write('entryId: $entryId, ')
          ..write('subjectId: $subjectId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TiersTable tiers = $TiersTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $EntrySubjectsTable entrySubjects = $EntrySubjectsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tiers,
    subjects,
    entries,
    entrySubjects,
  ];
}

typedef $$TiersTableCreateCompanionBuilder =
    TiersCompanion Function({
      Value<int> id,
      required String name,
      Value<String> emoji,
      required int colorValue,
      required double tierSort,
      Value<bool> isInbox,
      Value<DateTime> createdAt,
    });
typedef $$TiersTableUpdateCompanionBuilder =
    TiersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> emoji,
      Value<int> colorValue,
      Value<double> tierSort,
      Value<bool> isInbox,
      Value<DateTime> createdAt,
    });

final class $$TiersTableReferences
    extends BaseReferences<_$AppDatabase, $TiersTable, Tier> {
  $$TiersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: $_aliasNameGenerator(db.tiers.id, db.entries.tierId),
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.tierId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TiersTableFilterComposer extends Composer<_$AppDatabase, $TiersTable> {
  $$TiersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tierSort => $composableBuilder(
    column: $table.tierSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInbox => $composableBuilder(
    column: $table.isInbox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.tierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TiersTableOrderingComposer
    extends Composer<_$AppDatabase, $TiersTable> {
  $$TiersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tierSort => $composableBuilder(
    column: $table.tierSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInbox => $composableBuilder(
    column: $table.isInbox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TiersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TiersTable> {
  $$TiersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tierSort =>
      $composableBuilder(column: $table.tierSort, builder: (column) => column);

  GeneratedColumn<bool> get isInbox =>
      $composableBuilder(column: $table.isInbox, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.tierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TiersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TiersTable,
          Tier,
          $$TiersTableFilterComposer,
          $$TiersTableOrderingComposer,
          $$TiersTableAnnotationComposer,
          $$TiersTableCreateCompanionBuilder,
          $$TiersTableUpdateCompanionBuilder,
          (Tier, $$TiersTableReferences),
          Tier,
          PrefetchHooks Function({bool entriesRefs})
        > {
  $$TiersTableTableManager(_$AppDatabase db, $TiersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TiersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TiersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TiersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<double> tierSort = const Value.absent(),
                Value<bool> isInbox = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TiersCompanion(
                id: id,
                name: name,
                emoji: emoji,
                colorValue: colorValue,
                tierSort: tierSort,
                isInbox: isInbox,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> emoji = const Value.absent(),
                required int colorValue,
                required double tierSort,
                Value<bool> isInbox = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TiersCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                colorValue: colorValue,
                tierSort: tierSort,
                isInbox: isInbox,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TiersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({entriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (entriesRefs) db.entries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entriesRefs)
                    await $_getPrefetchedData<Tier, $TiersTable, Entry>(
                      currentTable: table,
                      referencedTable: $$TiersTableReferences._entriesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TiersTableReferences(db, table, p0).entriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tierId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TiersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TiersTable,
      Tier,
      $$TiersTableFilterComposer,
      $$TiersTableOrderingComposer,
      $$TiersTableAnnotationComposer,
      $$TiersTableCreateCompanionBuilder,
      $$TiersTableUpdateCompanionBuilder,
      (Tier, $$TiersTableReferences),
      Tier,
      PrefetchHooks Function({bool entriesRefs})
    >;
typedef $$SubjectsTableCreateCompanionBuilder =
    SubjectsCompanion Function({
      Value<int> subjectId,
      Value<String> nameCn,
      Value<String> nameJp,
      Value<String> posterUrl,
      Value<String> airDate,
      Value<int> eps,
      Value<double> rating,
      Value<String> summary,
      Value<DateTime> lastFetchedAt,
    });
typedef $$SubjectsTableUpdateCompanionBuilder =
    SubjectsCompanion Function({
      Value<int> subjectId,
      Value<String> nameCn,
      Value<String> nameJp,
      Value<String> posterUrl,
      Value<String> airDate,
      Value<int> eps,
      Value<double> rating,
      Value<String> summary,
      Value<DateTime> lastFetchedAt,
    });

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: $_aliasNameGenerator(
      db.subjects.subjectId,
      db.entries.primarySubjectId,
    ),
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager($_db, $_db.entries).filter(
      (f) => f.primarySubjectId.subjectId.sqlEquals(
        $_itemColumn<int>('subject_id')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntrySubjectsTable, List<EntrySubject>>
  _entrySubjectsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entrySubjects,
    aliasName: $_aliasNameGenerator(
      db.subjects.subjectId,
      db.entrySubjects.subjectId,
    ),
  );

  $$EntrySubjectsTableProcessedTableManager get entrySubjectsRefs {
    final manager = $$EntrySubjectsTableTableManager($_db, $_db.entrySubjects)
        .filter(
          (f) =>
              f.subjectId.subjectId.sqlEquals($_itemColumn<int>('subject_id')!),
        );

    final cache = $_typedResult.readTableOrNull(_entrySubjectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameCn => $composableBuilder(
    column: $table.nameCn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameJp => $composableBuilder(
    column: $table.nameJp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get airDate => $composableBuilder(
    column: $table.airDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eps => $composableBuilder(
    column: $table.eps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.primarySubjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> entrySubjectsRefs(
    Expression<bool> Function($$EntrySubjectsTableFilterComposer f) f,
  ) {
    final $$EntrySubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.entrySubjects,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntrySubjectsTableFilterComposer(
            $db: $db,
            $table: $db.entrySubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameCn => $composableBuilder(
    column: $table.nameCn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameJp => $composableBuilder(
    column: $table.nameJp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get airDate => $composableBuilder(
    column: $table.airDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eps => $composableBuilder(
    column: $table.eps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get nameCn =>
      $composableBuilder(column: $table.nameCn, builder: (column) => column);

  GeneratedColumn<String> get nameJp =>
      $composableBuilder(column: $table.nameJp, builder: (column) => column);

  GeneratedColumn<String> get posterUrl =>
      $composableBuilder(column: $table.posterUrl, builder: (column) => column);

  GeneratedColumn<String> get airDate =>
      $composableBuilder(column: $table.airDate, builder: (column) => column);

  GeneratedColumn<int> get eps =>
      $composableBuilder(column: $table.eps, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => column,
  );

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.primarySubjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> entrySubjectsRefs<T extends Object>(
    Expression<T> Function($$EntrySubjectsTableAnnotationComposer a) f,
  ) {
    final $$EntrySubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.entrySubjects,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntrySubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.entrySubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, $$SubjectsTableReferences),
          Subject,
          PrefetchHooks Function({bool entriesRefs, bool entrySubjectsRefs})
        > {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> subjectId = const Value.absent(),
                Value<String> nameCn = const Value.absent(),
                Value<String> nameJp = const Value.absent(),
                Value<String> posterUrl = const Value.absent(),
                Value<String> airDate = const Value.absent(),
                Value<int> eps = const Value.absent(),
                Value<double> rating = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<DateTime> lastFetchedAt = const Value.absent(),
              }) => SubjectsCompanion(
                subjectId: subjectId,
                nameCn: nameCn,
                nameJp: nameJp,
                posterUrl: posterUrl,
                airDate: airDate,
                eps: eps,
                rating: rating,
                summary: summary,
                lastFetchedAt: lastFetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> subjectId = const Value.absent(),
                Value<String> nameCn = const Value.absent(),
                Value<String> nameJp = const Value.absent(),
                Value<String> posterUrl = const Value.absent(),
                Value<String> airDate = const Value.absent(),
                Value<int> eps = const Value.absent(),
                Value<double> rating = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<DateTime> lastFetchedAt = const Value.absent(),
              }) => SubjectsCompanion.insert(
                subjectId: subjectId,
                nameCn: nameCn,
                nameJp: nameJp,
                posterUrl: posterUrl,
                airDate: airDate,
                eps: eps,
                rating: rating,
                summary: summary,
                lastFetchedAt: lastFetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({entriesRefs = false, entrySubjectsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entriesRefs) db.entries,
                    if (entrySubjectsRefs) db.entrySubjects,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entriesRefs)
                        await $_getPrefetchedData<
                          Subject,
                          $SubjectsTable,
                          Entry
                        >(
                          currentTable: table,
                          referencedTable: $$SubjectsTableReferences
                              ._entriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).entriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.primarySubjectId == item.subjectId,
                              ),
                          typedResults: items,
                        ),
                      if (entrySubjectsRefs)
                        await $_getPrefetchedData<
                          Subject,
                          $SubjectsTable,
                          EntrySubject
                        >(
                          currentTable: table,
                          referencedTable: $$SubjectsTableReferences
                              ._entrySubjectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).entrySubjectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subjectId == item.subjectId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, $$SubjectsTableReferences),
      Subject,
      PrefetchHooks Function({bool entriesRefs, bool entrySubjectsRefs})
    >;
typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      required int tierId,
      required int primarySubjectId,
      required double entryRank,
      Value<String> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<int> id,
      Value<int> tierId,
      Value<int> primarySubjectId,
      Value<double> entryRank,
      Value<String> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$EntriesTableReferences
    extends BaseReferences<_$AppDatabase, $EntriesTable, Entry> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TiersTable _tierIdTable(_$AppDatabase db) => db.tiers.createAlias(
    $_aliasNameGenerator(db.entries.tierId, db.tiers.id),
  );

  $$TiersTableProcessedTableManager get tierId {
    final $_column = $_itemColumn<int>('tier_id')!;

    final manager = $$TiersTableTableManager(
      $_db,
      $_db.tiers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubjectsTable _primarySubjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias(
        $_aliasNameGenerator(
          db.entries.primarySubjectId,
          db.subjects.subjectId,
        ),
      );

  $$SubjectsTableProcessedTableManager get primarySubjectId {
    final $_column = $_itemColumn<int>('primary_subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.subjectId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_primarySubjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntrySubjectsTable, List<EntrySubject>>
  _entrySubjectsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.entrySubjects,
    aliasName: $_aliasNameGenerator(db.entries.id, db.entrySubjects.entryId),
  );

  $$EntrySubjectsTableProcessedTableManager get entrySubjectsRefs {
    final manager = $$EntrySubjectsTableTableManager(
      $_db,
      $_db.entrySubjects,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entrySubjectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get entryRank => $composableBuilder(
    column: $table.entryRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TiersTableFilterComposer get tierId {
    final $$TiersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tierId,
      referencedTable: $db.tiers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TiersTableFilterComposer(
            $db: $db,
            $table: $db.tiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableFilterComposer get primarySubjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primarySubjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entrySubjectsRefs(
    Expression<bool> Function($$EntrySubjectsTableFilterComposer f) f,
  ) {
    final $$EntrySubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entrySubjects,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntrySubjectsTableFilterComposer(
            $db: $db,
            $table: $db.entrySubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get entryRank => $composableBuilder(
    column: $table.entryRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TiersTableOrderingComposer get tierId {
    final $$TiersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tierId,
      referencedTable: $db.tiers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TiersTableOrderingComposer(
            $db: $db,
            $table: $db.tiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableOrderingComposer get primarySubjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primarySubjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get entryRank =>
      $composableBuilder(column: $table.entryRank, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TiersTableAnnotationComposer get tierId {
    final $$TiersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tierId,
      referencedTable: $db.tiers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TiersTableAnnotationComposer(
            $db: $db,
            $table: $db.tiers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableAnnotationComposer get primarySubjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.primarySubjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entrySubjectsRefs<T extends Object>(
    Expression<T> Function($$EntrySubjectsTableAnnotationComposer a) f,
  ) {
    final $$EntrySubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entrySubjects,
      getReferencedColumn: (t) => t.entryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntrySubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.entrySubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, $$EntriesTableReferences),
          Entry,
          PrefetchHooks Function({
            bool tierId,
            bool primarySubjectId,
            bool entrySubjectsRefs,
          })
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> tierId = const Value.absent(),
                Value<int> primarySubjectId = const Value.absent(),
                Value<double> entryRank = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                tierId: tierId,
                primarySubjectId: primarySubjectId,
                entryRank: entryRank,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int tierId,
                required int primarySubjectId,
                required double entryRank,
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                tierId: tierId,
                primarySubjectId: primarySubjectId,
                entryRank: entryRank,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tierId = false,
                primarySubjectId = false,
                entrySubjectsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entrySubjectsRefs) db.entrySubjects,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tierId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tierId,
                                    referencedTable: $$EntriesTableReferences
                                        ._tierIdTable(db),
                                    referencedColumn: $$EntriesTableReferences
                                        ._tierIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (primarySubjectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.primarySubjectId,
                                    referencedTable: $$EntriesTableReferences
                                        ._primarySubjectIdTable(db),
                                    referencedColumn: $$EntriesTableReferences
                                        ._primarySubjectIdTable(db)
                                        .subjectId,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entrySubjectsRefs)
                        await $_getPrefetchedData<
                          Entry,
                          $EntriesTable,
                          EntrySubject
                        >(
                          currentTable: table,
                          referencedTable: $$EntriesTableReferences
                              ._entrySubjectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).entrySubjectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.entryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, $$EntriesTableReferences),
      Entry,
      PrefetchHooks Function({
        bool tierId,
        bool primarySubjectId,
        bool entrySubjectsRefs,
      })
    >;
typedef $$EntrySubjectsTableCreateCompanionBuilder =
    EntrySubjectsCompanion Function({
      required int entryId,
      required int subjectId,
      Value<int> rowid,
    });
typedef $$EntrySubjectsTableUpdateCompanionBuilder =
    EntrySubjectsCompanion Function({
      Value<int> entryId,
      Value<int> subjectId,
      Value<int> rowid,
    });

final class $$EntrySubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $EntrySubjectsTable, EntrySubject> {
  $$EntrySubjectsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EntriesTable _entryIdTable(_$AppDatabase db) =>
      db.entries.createAlias(
        $_aliasNameGenerator(db.entrySubjects.entryId, db.entries.id),
      );

  $$EntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias(
        $_aliasNameGenerator(db.entrySubjects.subjectId, db.subjects.subjectId),
      );

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<int>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.subjectId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntrySubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $EntrySubjectsTable> {
  $$EntrySubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntriesTableFilterComposer get entryId {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntrySubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntrySubjectsTable> {
  $$EntrySubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntriesTableOrderingComposer get entryId {
    final $$EntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntrySubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntrySubjectsTable> {
  $$EntrySubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$EntriesTableAnnotationComposer get entryId {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntrySubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntrySubjectsTable,
          EntrySubject,
          $$EntrySubjectsTableFilterComposer,
          $$EntrySubjectsTableOrderingComposer,
          $$EntrySubjectsTableAnnotationComposer,
          $$EntrySubjectsTableCreateCompanionBuilder,
          $$EntrySubjectsTableUpdateCompanionBuilder,
          (EntrySubject, $$EntrySubjectsTableReferences),
          EntrySubject,
          PrefetchHooks Function({bool entryId, bool subjectId})
        > {
  $$EntrySubjectsTableTableManager(_$AppDatabase db, $EntrySubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntrySubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntrySubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntrySubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> entryId = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntrySubjectsCompanion(
                entryId: entryId,
                subjectId: subjectId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int entryId,
                required int subjectId,
                Value<int> rowid = const Value.absent(),
              }) => EntrySubjectsCompanion.insert(
                entryId: entryId,
                subjectId: subjectId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntrySubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false, subjectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$EntrySubjectsTableReferences
                                    ._entryIdTable(db),
                                referencedColumn: $$EntrySubjectsTableReferences
                                    ._entryIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (subjectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.subjectId,
                                referencedTable: $$EntrySubjectsTableReferences
                                    ._subjectIdTable(db),
                                referencedColumn: $$EntrySubjectsTableReferences
                                    ._subjectIdTable(db)
                                    .subjectId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EntrySubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntrySubjectsTable,
      EntrySubject,
      $$EntrySubjectsTableFilterComposer,
      $$EntrySubjectsTableOrderingComposer,
      $$EntrySubjectsTableAnnotationComposer,
      $$EntrySubjectsTableCreateCompanionBuilder,
      $$EntrySubjectsTableUpdateCompanionBuilder,
      (EntrySubject, $$EntrySubjectsTableReferences),
      EntrySubject,
      PrefetchHooks Function({bool entryId, bool subjectId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TiersTableTableManager get tiers =>
      $$TiersTableTableManager(_db, _db.tiers);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$EntrySubjectsTableTableManager get entrySubjects =>
      $$EntrySubjectsTableTableManager(_db, _db.entrySubjects);
}
