import 'dart:io';

import 'package:anime_shelf/core/window/window_controls.dart';
import 'package:anime_shelf/core/window/window_settings_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

/// A fused application bar that merges the standard Material [AppBar] with
/// window-management controls on Linux desktop (when the native title bar is
/// hidden).
///
/// On mobile — or when the system title bar is visible — this behaves
/// identically to a normal [AppBar].  On Linux with a hidden title bar it:
///
///  1. Appends minimise / maximise / close buttons after [actions].
///  2. Wraps the entire bar in a [DragToMoveArea] so users can drag the
///     window from any empty spot on the toolbar.
class FusedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const FusedAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.scrolledUnderElevation,
    this.centerTitle,
    this.titleSpacing,
  });

  /// Primary widget displayed in the app bar (e.g. text title, search box).
  final Widget? title;

  /// Action buttons placed before the window controls.
  final List<Widget>? actions;

  /// Widget displayed before the [title].
  final Widget? leading;

  /// {@macro flutter.material.appbar.automaticallyImplyLeading}
  final bool automaticallyImplyLeading;

  /// Override the default [AppBar] background colour.
  final Color? backgroundColor;

  /// Override the default [AppBar] foreground colour.
  final Color? foregroundColor;

  /// Elevation of the app bar surface.
  final double? elevation;

  /// Elevation when content is scrolled underneath.
  final double? scrolledUnderElevation;

  /// Whether the [title] should be centred.
  final bool? centerTitle;

  /// Spacing around the [title] widget.
  final double? titleSpacing;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktopCustomBar =
        Platform.isLinux && ref.watch(windowSettingsNotifierProvider);

    final effectiveActions = <Widget>[
      ...?actions,
      if (isDesktopCustomBar) ...[
        // Thin vertical separator between app actions and window controls.
        SizedBox(
          height: 24,
          child: VerticalDivider(
            width: 16,
            thickness: 1,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        const WindowControls(),
        const SizedBox(width: 4),
      ],
    ];

    final appBar = AppBar(
      title: title,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: effectiveActions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
    );

    if (isDesktopCustomBar) {
      return DragToMoveArea(child: appBar);
    }

    return appBar;
  }
}
