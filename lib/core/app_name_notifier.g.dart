// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_name_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appNameNotifierHash() => r'e6ba423e35aecbe78cb10e59a8f787d91c9512e0';

/// Manages the user-facing display name of the application.
///
/// Persisted via [SharedPreferences].  Defaults to `'动漫书架'`.
/// The name is shown in the [FusedAppBar] leading area on desktop and
/// can be edited from the Settings → Window section.
///
/// Copied from [AppNameNotifier].
@ProviderFor(AppNameNotifier)
final appNameNotifierProvider =
    NotifierProvider<AppNameNotifier, String>.internal(
      AppNameNotifier.new,
      name: r'appNameNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appNameNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppNameNotifier = Notifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
