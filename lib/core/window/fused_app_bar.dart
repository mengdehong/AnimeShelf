import 'dart:io';

import 'package:anime_shelf/core/app_name_notifier.dart';
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
///  3. Optionally shows the user-editable app name on the far left via
///     [showAppName] — intended for root-level pages where there is no
///     back button competing for the leading slot.
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
    this.showAppName = false,
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

  /// When `true` and running in desktop custom-title-bar mode, shows the
  /// user-editable app display name on the far left of the bar.
  ///
  /// Designed for root pages (e.g. [ShelfPage]) that have no back button.
  /// The layout uses a [Row] so a logo widget can be slotted in later by
  /// simply prepending an [Icon] or [Image] to the row children.
  final bool showAppName;

  /// Width reserved for the app-name leading area.
  static const double _appNameLeadingWidth = 130.0;

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

    // Build the leading app-name widget only on desktop with custom bar.
    final Widget? effectiveLeading;
    final double? effectiveLeadingWidth;
    if (showAppName && isDesktopCustomBar) {
      final appName = ref.watch(appNameNotifierProvider);
      effectiveLeading = _AppNameLeading(name: appName);
      effectiveLeadingWidth = _appNameLeadingWidth;
    } else {
      effectiveLeading = leading;
      effectiveLeadingWidth = null;
    }

    final appBar = AppBar(
      title: title,
      leading: effectiveLeading,
      automaticallyImplyLeading: showAppName && isDesktopCustomBar
          ? false
          : automaticallyImplyLeading,
      leadingWidth: effectiveLeadingWidth,
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

/// The leading widget that shows the app display name.
///
/// Uses a [Row] intentionally — a logo [Widget] (icon or image) can be
/// prepended to [_children] in the future without restructuring the layout.
class _AppNameLeading extends StatelessWidget {
  const _AppNameLeading({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.75);

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TODO: slot a logo widget here in the future, e.g.:
          // Icon(Icons.play_circle_outline, size: 18, color: color),
          // const SizedBox(width: 6),
          Text(
            name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
