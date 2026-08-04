import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/address/domain/entities/address.dart';
import '../../features/address/presentation/screens/address_form_screen.dart';
import '../../features/address/presentation/screens/address_list_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/catalog/presentation/screens/bundle_detail_screen.dart';
import '../../features/catalog/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/search_screen.dart';
import '../../features/orders/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/order_history_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/rewards/presentation/screens/rewards_home_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../providers/onboarding_provider.dart';
import '../providers/supabase_provider.dart';
import 'go_router_refresh_stream.dart';
import 'route_names.dart';

/// GoRouter instance, exposed via Riverpod.
///
/// Redirect strategy:
/// - The splash route always decides its own destination explicitly
///   (see [SplashScreen]) rather than being redirected away from —
///   this keeps the "where do we land on cold start" decision in one
///   readable place instead of split across a redirect callback.
/// - Once past splash, `redirect:` enforces two invariants continuously:
///   an authenticated user can't land back on onboarding/login/OTP, and
///   an unauthenticated user can't reach protected routes (currently
///   just `/home`; more are added as features gate behind auth).
/// - `refreshListenable` re-runs redirect whenever Supabase's auth
///   stream emits, so a session expiring or being revoked elsewhere
///   bounces the user out of protected screens immediately rather than
///   only on next navigation.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final bool hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboarding,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.otpVerify,
        name: RouteNames.otpVerify,
        builder: (BuildContext context, GoRouterState state) {
          final String phone = state.extra as String? ?? '';
          return OtpVerifyScreen(phone: phone);
        },
      ),
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.search,
        name: RouteNames.search,
        builder: (BuildContext context, GoRouterState state) =>
            const SearchScreen(),
      ),
      GoRoute(
        path: '${RouteNames.bundleDetail}/:id',
        name: RouteNames.bundleDetail,
        builder: (BuildContext context, GoRouterState state) {
          final String bundleId = state.pathParameters['id']!;
          return BundleDetailScreen(bundleId: bundleId);
        },
      ),
      GoRoute(
        path: RouteNames.cart,
        name: RouteNames.cart,
        builder: (BuildContext context, GoRouterState state) => const CartScreen(),
      ),
      GoRoute(
        path: RouteNames.checkout,
        name: RouteNames.checkout,
        builder: (BuildContext context, GoRouterState state) =>
            const CheckoutScreen(),
      ),
      GoRoute(
        path: RouteNames.orderHistory,
        name: 'order-history',
        builder: (BuildContext context, GoRouterState state) =>
            const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '${RouteNames.orderHistory}/:id',
        name: 'order-detail',
        builder: (BuildContext context, GoRouterState state) {
          final String orderId = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteNames.addresses,
        name: RouteNames.addresses,
        builder: (BuildContext context, GoRouterState state) =>
            const AddressListScreen(),
      ),
      GoRoute(
        path: RouteNames.addressForm,
        name: RouteNames.addressForm,
        builder: (BuildContext context, GoRouterState state) {
          final Address? existing = state.extra as Address?;
          return AddressFormScreen(existing: existing);
        },
      ),
      GoRoute(
        path: RouteNames.rewards,
        name: RouteNames.rewards,
        builder: (BuildContext context, GoRouterState state) =>
            const RewardsHomeScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: RouteNames.profile,
        builder: (BuildContext context, GoRouterState state) =>
            const ProfileScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final String path = state.matchedLocation;
      if (path == RouteNames.splash) return null;

      final bool loggedIn = authRepository.currentUser != null;
      final bool isOnboardingRoute = path == RouteNames.onboarding;
      final bool isAuthRoute =
          path == RouteNames.login || path == RouteNames.otpVerify;
      final bool isProtectedRoute = path == RouteNames.home ||
          path == RouteNames.search ||
          path == RouteNames.cart ||
          path == RouteNames.checkout ||
          path == RouteNames.addresses ||
          path == RouteNames.addressForm ||
          path == RouteNames.rewards ||
          path == RouteNames.profile ||
          path.startsWith(RouteNames.bundleDetail) ||
          path.startsWith(RouteNames.orderHistory);

      if (loggedIn) {
        // Already signed in — don't let onboarding/login/OTP be reachable.
        return (isOnboardingRoute || isAuthRoute) ? RouteNames.home : null;
      }

      // Not signed in — protected routes bounce to the right auth step.
      if (isProtectedRoute) {
        return hasSeenOnboarding ? RouteNames.login : RouteNames.onboarding;
      }
      return null;
    },
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri.path}'),
      ),
    ),
  );
});
