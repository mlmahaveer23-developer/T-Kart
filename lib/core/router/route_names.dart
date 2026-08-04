/// Central registry of route paths and names. Every `context.go(...)` /
/// `context.push(...)` call in the app should reference these constants
/// instead of string-literal paths, so renaming a route is a one-line
/// change instead of a project-wide find/replace.
class RouteNames {
  const RouteNames._();

  // Bootstrap
  static const String splash = '/';

  // Auth (Phase 2)
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otpVerify = '/otp-verify';

  // Catalog (Phase 3)
  static const String home = '/home';
  static const String search = '/search';

  // Bundle detail & cart (Phase 4)
  static const String bundleDetail = '/bundle';
  static const String cart = '/cart';

  // Checkout & orders (Phase 5)
  static const String checkout = '/checkout';

  /// Also the path prefix for order detail: `$orderHistory/:id`.
  static const String orderHistory = '/orders';
  static const String addresses = '/addresses';
  static const String addressForm = '/addresses/form';

  // Rewards & referral (Phase 6)
  static const String rewards = '/rewards';

  // Profile & settings (Phase 7)
  static const String profile = '/profile';
}
