import 'package:flutter/material.dart';

/// Tribhuban Concepts design language.
///
/// Deliberately steers away from the blue/green-on-white "delivery app"
/// look used by Blinkit/Instamart/Zepto/BigBasket. The palette is built
/// around a deep forest green (trust, freshness, grocery heritage) paired
/// with a warm brass/gold accent (premium, reward, bundle value) on a
/// warm ivory surface rather than clinical white — evoking a modern
/// Indian pantry-store feel rather than a generic e-commerce template.
class AppColors {
  const AppColors._();

  // ---- Brand ----
  static const Color forest900 = Color(0xFF0E2A22); // deepest brand ink
  static const Color forest700 = Color(0xFF15452F); // primary
  static const Color forest500 = Color(0xFF1F6B47);
  static const Color forest300 = Color(0xFF6FA98A);
  static const Color forest100 = Color(0xFFDCEBE2);

  static const Color brass600 = Color(0xFFB8863B); // primary accent
  static const Color brass400 = Color(0xFFD3A85C);
  static const Color brass200 = Color(0xFFF0DFB8);
  static const Color brass50 = Color(0xFFFBF3E3);

  // ---- Neutrals (warm-toned, not pure gray) ----
  static const Color ink900 = Color(0xFF1C1A17);
  static const Color ink700 = Color(0xFF3A3733);
  static const Color ink500 = Color(0xFF6B655D);
  static const Color ink300 = Color(0xFFA39C91);
  static const Color ink100 = Color(0xFFE7E1D6);

  static const Color ivory = Color(0xFFFBF8F2); // light bg
  static const Color ivoryDim = Color(0xFFF3EEE3); // light surface-alt
  static const Color pureWhite = Color(0xFFFFFFFF);

  static const Color charcoal900 = Color(0xFF14120F); // dark bg
  static const Color charcoal800 = Color(0xFF1E1B17); // dark surface
  static const Color charcoal700 = Color(0xFF2A2621);

  // ---- Semantic ----
  static const Color success = Color(0xFF2E7D4F);
  static const Color warning = Color(0xFFC08A1E);
  static const Color error = Color(0xFFB3413A);
  static const Color info = Color(0xFF2E6E8E);

  // ---- Reward / bundle accent (used sparingly for the ₹2,500 rewards
  // system, coupons, referral highlights — gives them a distinct
  // "special" visual identity separate from primary actions) ----
  static const Color rewardGradientStart = Color(0xFFB8863B);
  static const Color rewardGradientEnd = Color(0xFF7A4E17);
}
