import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Static helpers so every feature shows feedback the same way instead
/// of constructing `SnackBar`/`ScaffoldMessenger` boilerplate per call
/// site.
class AppSnackbar {
  const AppSnackbar._();

  static void success(BuildContext context, String message) =>
      _show(context, message, icon: Icons.check_circle_rounded, accent: AppColors.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, icon: Icons.error_rounded, accent: AppColors.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, icon: Icons.info_rounded, accent: AppColors.info);

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color accent,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
