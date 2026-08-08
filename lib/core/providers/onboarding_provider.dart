import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String prefsKeyOnboardingSeen = 'tc_onboarding_seen';

/// Whether the user has completed the onboarding carousel.
///
/// Overridden in `main.dart` with a value read from SharedPreferences
/// *before* `runApp`, so the router's redirect logic (which cannot
/// await) always has a synchronous, correct answer from first frame.
/// The onboarding screen flips this via [OnboardingSeen.markSeen] when
/// the user taps "Get Started", and persists it for next launch.
final StateProvider<bool> hasSeenOnboardingProvider =
    StateProvider<bool>((Ref ref) => false);

class OnboardingSeen {
  const OnboardingSeen._();

  static Future<bool> readFromDisk() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKeyOnboardingSeen) ?? false;
  }

  static Future<void> markSeen(WidgetRef ref) async {
    ref.read(hasSeenOnboardingProvider.notifier).state = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKeyOnboardingSeen, true);
  }
}
