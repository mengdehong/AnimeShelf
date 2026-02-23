// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'397e5c893a29d7b17310deb6724df71242a8ab08';

/// Global database provider — single instance for the app lifetime.
///
/// Copied from [database].
@ProviderFor(database)
final databaseProvider = Provider<AppDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseRef = ProviderRef<AppDatabase>;
String _$bangumiClientHash() => r'd70fe28ac122b30617b77f37b5ccb66921b7c8e8';

/// Global Bangumi API client provider.
///
/// Copied from [bangumiClient].
@ProviderFor(bangumiClient)
final bangumiClientProvider = Provider<BangumiClient>.internal(
  bangumiClient,
  name: r'bangumiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bangumiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BangumiClientRef = ProviderRef<BangumiClient>;
String _$localImageServiceHash() => r'9daf83cdec1d33e4c7c546c57110559e467d8311';

/// Global local image service provider.
///
/// Copied from [localImageService].
@ProviderFor(localImageService)
final localImageServiceProvider = Provider<LocalImageService>.internal(
  localImageService,
  name: r'localImageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localImageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalImageServiceRef = ProviderRef<LocalImageService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
