import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/onboarding_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/app_user.dart';

/// Bootstrap screen — the single place that decides where a cold start
/// lands: straight to Home if a session already exists, otherwise
/// Login (if onboarding was seen before) or the Onboarding carousel
/// (first-ever launch). Kept as an explicit decision here rather than
/// folded into the router's `redirect:` so the cold-start logic reads
/// top-to-bottom in one place.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideDestination();
  }

  Future<void> _decideDestination() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final AppUser? currentUser =
        ref.read(authRepositoryProvider).currentUser;

    if (currentUser != null) {
      context.go(RouteNames.home);
      return;
    }

    final bool hasSeenOnboarding = ref.read(hasSeenOnboardingProvider);
    context.go(hasSeenOnboarding ? RouteNames.login : RouteNames.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.storefront_rounded,
              size: 56,
              color: scheme.onPrimary,
            ).animate().fadeIn(duration: 400.ms).scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppConstants.appName,
              style: text.headlineMedium?.copyWith(color: scheme.onPrimary),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
