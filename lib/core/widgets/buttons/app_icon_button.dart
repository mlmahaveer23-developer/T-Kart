import 'package:flutter/material.dart';

/// Circular, tonal icon button — used for things like favorite/wishlist
/// toggles, back buttons over images, and cart quantity steppers.
/// Distinct from a plain [IconButton] so it always gets a soft filled
/// background rather than being invisible on busy backgrounds.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.size = 40,
    this.iconSize = 20,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final Widget button = Material(
      color: backgroundColor ?? scheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: iconSize,
            color: onPressed == null
                ? scheme.outline
                : (foregroundColor ?? scheme.onSurface),
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
