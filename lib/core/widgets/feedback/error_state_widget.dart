import 'package:flutter/material.dart';
import '../../error/failures.dart';
import '../../theme/app_spacing.dart';
import '../buttons/app_button.dart';

/// Standard error state, driven directly by a domain [Failure] so
/// feature screens don't re-decide copy/iconography per error type —
/// they just pass the Failure they got back from a repository call.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    required this.failure,
    super.key,
    this.onRetry,
  });

  final Failure failure;
  final VoidCallback? onRetry;

  IconData get _icon => switch (failure) {
        NetworkFailure() => Icons.wifi_off_rounded,
        AuthFailure() => Icons.lock_outline_rounded,
        ServerFailure() => Icons.cloud_off_rounded,
        _ => Icons.error_outline_rounded,
      };

  String get _title => switch (failure) {
        NetworkFailure() => 'No internet connection',
        AuthFailure() => 'Session issue',
        ServerFailure() => 'Something went wrong',
        _ => 'Unexpected error',
      };

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(_icon, size: 44, color: scheme.error),
            const SizedBox(height: AppSpacing.lg),
            Text(_title, style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.outline),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Try again', onPressed: onRetry, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}
