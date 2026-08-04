import 'package:flutter/material.dart';

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// Content for the onboarding carousel. Kept as plain data (not
/// hardcoded widgets) so copy changes don't require touching layout
/// code, and so this can later be swapped for a remote-config-driven
/// list without changing the screen.
const List<OnboardingSlideData> onboardingSlides = <OnboardingSlideData>[
  OnboardingSlideData(
    icon: Icons.inventory_2_rounded,
    title: 'Everything your kitchen needs, bundled',
    description:
        'One monthly grocery bundle covers atta, rice, oil, dals, and '
        'more — no more juggling a dozen separate purchases.',
  ),
  OnboardingSlideData(
    icon: Icons.card_giftcard_rounded,
    title: 'Rewards worth up to ₹2,500',
    description:
        'Every ₹4,999 bundle unlocks bonus groceries, coupons for your '
        'next order, and referral rewards when friends join.',
  ),
  OnboardingSlideData(
    icon: Icons.storefront_rounded,
    title: 'Backed by your local retailer',
    description:
        'Shop online while staying connected to trusted neighbourhood '
        'stores — the best of both worlds.',
  ),
];
