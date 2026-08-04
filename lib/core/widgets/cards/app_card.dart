import 'package:flutter/material.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Base surface for any card-like content (product cards, list rows,
/// summary panels). Wraps the theme's CardTheme with an optional tap
/// ripple so features don't reach for raw `Card`/`InkWell` combos.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final CardThemeData cardTheme = Theme.of(context).cardTheme;

    return Card(
      margin: EdgeInsets.zero,
      color: cardTheme.color,
      shape: cardTheme.shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
