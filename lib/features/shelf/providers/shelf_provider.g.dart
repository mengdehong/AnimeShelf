// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shelfRepositoryHash() => r'c277cc2acc56e6029f5c7910dd16afae3918a5ef';

/// Provides the shelf repository instance.
///
/// Copied from [shelfRepository].
@ProviderFor(shelfRepository)
final shelfRepositoryProvider = Provider<ShelfRepository>.internal(
  shelfRepository,
  name: r'shelfRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shelfRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShelfRepositoryRef = ProviderRef<ShelfRepository>;
String _$shelfTiersHash() => r'2709f2f4374573459c7143bfbc96df06eebea298';

/// Watches all tiers with their entries for the shelf UI.
///
/// Copied from [shelfTiers].
@ProviderFor(shelfTiers)
final shelfTiersProvider =
    AutoDisposeStreamProvider<List<TierWithEntries>>.internal(
      shelfTiers,
      name: r'shelfTiersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shelfTiersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShelfTiersRef = AutoDisposeStreamProviderRef<List<TierWithEntries>>;
String _$shelfTierListHash() => r'ad30a9313891ffcacb82c6f8d16f9bd3a1a4e2c5';

/// Watches tier list only, ordered by tierSort.
///
/// Copied from [shelfTierList].
@ProviderFor(shelfTierList)
final shelfTierListProvider = AutoDisposeStreamProvider<List<Tier>>.internal(
  shelfTierList,
  name: r'shelfTierListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shelfTierListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShelfTierListRef = AutoDisposeStreamProviderRef<List<Tier>>;
String _$tierEntriesHash() => r'8a039e071c29d8dc8e18a0f2d4e4aadaa117de9d';

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

/// Watches entries for one tier.
///
/// Copied from [tierEntries].
@ProviderFor(tierEntries)
const tierEntriesProvider = TierEntriesFamily();

/// Watches entries for one tier.
///
/// Copied from [tierEntries].
class TierEntriesFamily extends Family<AsyncValue<List<EntryWithSubject>>> {
  /// Watches entries for one tier.
  ///
  /// Copied from [tierEntries].
  const TierEntriesFamily();

  /// Watches entries for one tier.
  ///
  /// Copied from [tierEntries].
  TierEntriesProvider call(int tierId) {
    return TierEntriesProvider(tierId);
  }

  @override
  TierEntriesProvider getProviderOverride(
    covariant TierEntriesProvider provider,
  ) {
    return call(provider.tierId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tierEntriesProvider';
}

/// Watches entries for one tier.
///
/// Copied from [tierEntries].
class TierEntriesProvider
    extends AutoDisposeStreamProvider<List<EntryWithSubject>> {
  /// Watches entries for one tier.
  ///
  /// Copied from [tierEntries].
  TierEntriesProvider(int tierId)
    : this._internal(
        (ref) => tierEntries(ref as TierEntriesRef, tierId),
        from: tierEntriesProvider,
        name: r'tierEntriesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tierEntriesHash,
        dependencies: TierEntriesFamily._dependencies,
        allTransitiveDependencies: TierEntriesFamily._allTransitiveDependencies,
        tierId: tierId,
      );

  TierEntriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tierId,
  }) : super.internal();

  final int tierId;

  @override
  Override overrideWith(
    Stream<List<EntryWithSubject>> Function(TierEntriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TierEntriesProvider._internal(
        (ref) => create(ref as TierEntriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tierId: tierId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<EntryWithSubject>> createElement() {
    return _TierEntriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TierEntriesProvider && other.tierId == tierId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tierId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TierEntriesRef on AutoDisposeStreamProviderRef<List<EntryWithSubject>> {
  /// The parameter `tierId` of this provider.
  int get tierId;
}

class _TierEntriesProviderElement
    extends AutoDisposeStreamProviderElement<List<EntryWithSubject>>
    with TierEntriesRef {
  _TierEntriesProviderElement(super.provider);

  @override
  int get tierId => (origin as TierEntriesProvider).tierId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
