// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$entryDetailHash() => r'ffe2ac4cb0bc49c2680826daa06b76303b61683e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$EntryDetail
    extends BuildlessAutoDisposeAsyncNotifier<EntryDetailData?> {
  late final int entryId;

  FutureOr<EntryDetailData?> build(int entryId);
}

/// Watches a single entry with its primary subject and current tier
/// for the detail page.
///
/// Copied from [EntryDetail].
@ProviderFor(EntryDetail)
const entryDetailProvider = EntryDetailFamily();

/// Watches a single entry with its primary subject and current tier
/// for the detail page.
///
/// Copied from [EntryDetail].
class EntryDetailFamily extends Family<AsyncValue<EntryDetailData?>> {
  /// Watches a single entry with its primary subject and current tier
  /// for the detail page.
  ///
  /// Copied from [EntryDetail].
  const EntryDetailFamily();

  /// Watches a single entry with its primary subject and current tier
  /// for the detail page.
  ///
  /// Copied from [EntryDetail].
  EntryDetailProvider call(int entryId) {
    return EntryDetailProvider(entryId);
  }

  @override
  EntryDetailProvider getProviderOverride(
    covariant EntryDetailProvider provider,
  ) {
    return call(provider.entryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'entryDetailProvider';
}

/// Watches a single entry with its primary subject and current tier
/// for the detail page.
///
/// Copied from [EntryDetail].
class EntryDetailProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<EntryDetail, EntryDetailData?> {
  /// Watches a single entry with its primary subject and current tier
  /// for the detail page.
  ///
  /// Copied from [EntryDetail].
  EntryDetailProvider(int entryId)
    : this._internal(
        () => EntryDetail()..entryId = entryId,
        from: entryDetailProvider,
        name: r'entryDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$entryDetailHash,
        dependencies: EntryDetailFamily._dependencies,
        allTransitiveDependencies: EntryDetailFamily._allTransitiveDependencies,
        entryId: entryId,
      );

  EntryDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.entryId,
  }) : super.internal();

  final int entryId;

  @override
  FutureOr<EntryDetailData?> runNotifierBuild(covariant EntryDetail notifier) {
    return notifier.build(entryId);
  }

  @override
  Override overrideWith(EntryDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: EntryDetailProvider._internal(
        () => create()..entryId = entryId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        entryId: entryId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<EntryDetail, EntryDetailData?>
  createElement() {
    return _EntryDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EntryDetailProvider && other.entryId == entryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, entryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EntryDetailRef on AutoDisposeAsyncNotifierProviderRef<EntryDetailData?> {
  /// The parameter `entryId` of this provider.
  int get entryId;
}

class _EntryDetailProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<EntryDetail, EntryDetailData?>
    with EntryDetailRef {
  _EntryDetailProviderElement(super.provider);

  @override
  int get entryId => (origin as EntryDetailProvider).entryId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
