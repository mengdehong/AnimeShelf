import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

/// A custom title bar shown on Linux desktop when the native OS title bar is
/// hidden. Provides a drag-to-move region, the application title, and
/// window control buttons (minimise / maximise / close).
class LinuxTitleBar extends ConsumerWidget implements PreferredSizeWidget {
  const LinuxTitleBar({super.key});

  static const double _height = 40.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surface;
    final foregroundColor = colorScheme.onSurface;

    return Material(
      color: backgroundColor,
      child: DragToMoveArea(
        child: SizedBox(
          height: _height,
          child: Row(
            children: [
              const SizedBox(width: 12),
              Text(
                'AnimeShelf',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _WindowControlButton(
                icon: Icons.remove,
                foregroundColor: foregroundColor,
                onPressed: () async => windowManager.minimize(),
              ),
              _MaximizeButton(foregroundColor: foregroundColor),
              _WindowControlButton(
                icon: Icons.close,
                foregroundColor: foregroundColor,
                isClose: true,
                onPressed: () async => windowManager.close(),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Maximize / restore toggle button that updates its icon based on window state.
class _MaximizeButton extends StatefulWidget {
  const _MaximizeButton({required this.foregroundColor});

  final Color foregroundColor;

  @override
  State<_MaximizeButton> createState() => _MaximizeButtonState();
}

class _MaximizeButtonState extends State<_MaximizeButton> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _checkMaximized() async {
    final maximized = await windowManager.isMaximized();
    if (mounted) {
      setState(() => _isMaximized = maximized);
    }
  }

  @override
  void onWindowMaximize() => setState(() => _isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _isMaximized = false);

  @override
  Widget build(BuildContext context) {
    return _WindowControlButton(
      icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
      foregroundColor: widget.foregroundColor,
      onPressed: () async {
        if (_isMaximized) {
          await windowManager.unmaximize();
        } else {
          await windowManager.maximize();
        }
      },
    );
  }
}

class _WindowControlButton extends StatelessWidget {
  const _WindowControlButton({
    required this.icon,
    required this.foregroundColor,
    required this.onPressed,
    this.isClose = false,
  });

  final IconData icon;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final bool isClose;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 16,
      highlightShape: BoxShape.rectangle,
      hoverColor: isClose
          ? Colors.red.withValues(alpha: 0.8)
          : foregroundColor.withValues(alpha: 0.12),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          icon,
          size: 16,
          color: foregroundColor.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
