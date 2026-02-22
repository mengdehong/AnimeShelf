// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$windowSettingsNotifierHash() =>
    r'1966b855a9c9bb65776bc3a973b7528ae215351a';

/// Whether the native OS title bar is hidden on Linux desktop.
/// Only meaningful when [Platform.isLinux] is true.
///
/// Copied from [WindowSettingsNotifier].
@ProviderFor(WindowSettingsNotifier)
final windowSettingsNotifierProvider =
    NotifierProvider<WindowSettingsNotifier, bool>.internal(
      WindowSettingsNotifier.new,
      name: r'windowSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$windowSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WindowSettingsNotifier = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
