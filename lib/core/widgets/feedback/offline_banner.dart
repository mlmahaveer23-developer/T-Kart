import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/connectivity_provider.dart';
import '../../theme/app_spacing.dart';

/// Slim banner that appears whenever connectivity drops, so screens
/// don't each implement their own offline detection. Mount once near
/// the top of the app shell (Phase 3) rather than per-screen.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<bool> connectivity = ref.watch(isConnectedProvider);
    final bool isOffline = connectivity.valueOrNull == false;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: isOffline
          ? Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    "You're offline",
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
