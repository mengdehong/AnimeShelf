import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Reusable window control buttons (minimise, maximise, close) for Linux
/// desktop when the native title bar is hidden.
///
/// Can be embedded in any toolbar — [FusedAppBar], [SliverAppBar], etc.
/// Pass [foregroundColor] / [buttonBackgroundColor] to adapt to overlay
/// contexts (e.g. floating over a poster image).
class WindowControls extends StatelessWidget {
  const WindowControls({
    super.key,
    this.foregroundColor,
    this.buttonBackgroundColor,
  });

  /// Icon colour for the control buttons.  Falls back to
  /// [ColorScheme.onSurface] when `null`.
  final Color? foregroundColor;

  /// Optional background fill behind each button (useful for overlay mode
  /// where buttons float over images).
  final Color? buttonBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WindowControlButton(
          icon: Icons.remove,
          foregroundColor: fg,
          backgroundColor: buttonBackgroundColor,
          onPressed: () async => windowManager.minimize(),
        ),
        _MaximizeButton(
          foregroundColor: fg,
          backgroundColor: buttonBackgroundColor,
        ),
        _WindowControlButton(
          icon: Icons.close,
          foregroundColor: fg,
          backgroundColor: buttonBackgroundColor,
          isClose: true,
          onPressed: () async => windowManager.close(),
        ),
      ],
    );
  }
}

/// Maximize / restore toggle button that updates its icon via
/// [WindowListener].
class _MaximizeButton extends StatefulWidget {
  const _MaximizeButton({required this.foregroundColor, this.backgroundColor});

  final Color foregroundColor;
  final Color? backgroundColor;

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
      backgroundColor: widget.backgroundColor,
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

/// A single window-control button with hover highlight.
class _WindowControlButton extends StatelessWidget {
  const _WindowControlButton({
    required this.icon,
    required this.foregroundColor,
    required this.onPressed,
    this.backgroundColor,
    this.isClose = false,
  });

  final IconData icon;
  final Color foregroundColor;
  final Color? backgroundColor;
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
      child: Container(
        width: 40,
        height: 40,
        decoration: backgroundColor != null
            ? BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Icon(
          icon,
          size: 16,
          color: foregroundColor.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
