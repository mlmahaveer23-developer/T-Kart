import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/providers/theme_mode_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/controllers/sign_out_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../widgets/profile_menu_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text("You'll need to verify your phone number again to sign back in."),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final bool success = await ref.read(signOutControllerProvider.notifier).signOut();
    if (!context.mounted) return;

    if (success) {
      // Clear the device-local cart on sign-out — it isn't scoped to a
      // user account (see Phase 4), so leaving it populated would leak
      // one person's cart to whoever signs in next on a shared device.
      await ref.read(cartControllerProvider.notifier).clear();
    } else {
      final Object? error = ref.read(signOutControllerProvider).error;
      AppSnackbar.error(
        context,
        error is Failure ? error.message : 'Could not sign out. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppUser? user = ref.watch(authRepositoryProvider).currentUser;
    final ThemeMode currentThemeMode = ref.watch(themeModeProvider);
    final bool isSigningOut = ref.watch(signOutControllerProvider).isLoading;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return AppScaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.person_rounded, color: scheme.primary, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user?.phone.isNotEmpty == true ? user!.phone : 'Signed in',
                      style: text.titleMedium,
                    ),
                    Text(
                      'Tribhuban Concepts customer',
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          const SectionHeader(title: 'Shopping'),
          ProfileMenuTile(
            icon: Icons.receipt_long_outlined,
            label: 'My Orders',
            onTap: () => context.push(RouteNames.orderHistory),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileMenuTile(
            icon: Icons.location_on_outlined,
            label: 'My Addresses',
            onTap: () => context.push(RouteNames.addresses),
          ),
          const SizedBox(height: AppSpacing.sm),
          ProfileMenuTile(
            icon: Icons.card_giftcard_rounded,
            label: 'My Rewards',
            onTap: () => context.push(RouteNames.rewards),
          ),

          const SizedBox(height: AppSpacing.xxl),
          const SectionHeader(title: 'Appearance'),
          AppCard(
            child: SegmentedButton<ThemeMode>(
              segments: const <ButtonSegment<ThemeMode>>[
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  icon: Icon(Icons.smartphone_outlined),
                  label: Text('System'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
              ],
              selected: <ThemeMode>{currentThemeMode},
              onSelectionChanged: (Set<ThemeMode> selection) {
                ref.read(themeModeProvider.notifier).setThemeMode(selection.first);
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'Sign Out',
            variant: AppButtonVariant.danger,
            isLoading: isSigningOut,
            onPressed: isSigningOut ? null : () => _confirmSignOut(context, ref),
          ),
        ],
      ),
    );
  }
}
