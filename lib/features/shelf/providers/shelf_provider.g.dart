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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
