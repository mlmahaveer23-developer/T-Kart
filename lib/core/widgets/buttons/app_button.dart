import 'package:flutter/material.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, danger, text }

enum AppButtonSize { medium, small }

/// Single button component used everywhere instead of raw
/// ElevatedButton/OutlinedButton — guarantees every CTA in the app has
/// identical sizing, corner radius, loading behavior, and disabled
/// styling with zero per-screen decisions.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.leadingIcon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? leadingIcon;

  /// Whether the button fills the available width. Set false for
  /// inline/paired buttons that should size to their content.
  final bool expand;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double height = size == AppButtonSize.medium ? 52 : 44;

    final Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(_foreground(scheme)),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (leadingIcon != null) ...<Widget>[
                Icon(leadingIcon, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label),
            ],
          );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(minimumSize: Size(0, height)),
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(minimumSize: Size(0, height)),
          child: child,
        ),
      AppButtonVariant.danger => ElevatedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.borderPill),
          ),
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: _isDisabled ? null : onPressed,
          style: TextButton.styleFrom(minimumSize: Size(0, height)),
          child: child,
        ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Color _foreground(ColorScheme scheme) => switch (variant) {
        AppButtonVariant.primary => scheme.onPrimary,
        AppButtonVariant.secondary => scheme.primary,
        AppButtonVariant.danger => scheme.onError,
        AppButtonVariant.text => scheme.primary,
      };
}
