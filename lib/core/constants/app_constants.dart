/// Non-secret, non-environment constants used across the app.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Tribhuban Concepts';

  // Business rules (Phase-0 known values; feature phases may extend these
  // into a remote-config-driven model instead of compile-time constants).
  static const int flagshipBundlePriceInRupees = 4999;
  static const int flagshipBundleRewardValueInRupees = 2500;

  // Secure storage keys
  static const String secureKeyAuthToken = 'tc_auth_token';
  static const String secureKeyRefreshToken = 'tc_refresh_token';

  // Animation durations — single source of truth so motion feels consistent
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
}
