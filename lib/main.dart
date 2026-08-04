import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/config/env_config.dart';
import 'core/providers/onboarding_provider.dart';
import 'core/utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
    debug: !EnvConfig.isProduction,
  );

  // Read synchronously-required prefs before runApp so the router's
  // redirect logic (which cannot await) has a correct answer from the
  // very first frame — no onboarding flash for returning users.
  final bool hasSeenOnboarding = await OnboardingSeen.readFromDisk();

  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error('Uncaught Flutter error', details.exception, details.stack);
    FlutterError.presentError(details);
  };

  runApp(
    ProviderScope(
      overrides: <Override>[
        hasSeenOnboardingProvider.overrideWith((Ref ref) => hasSeenOnboarding),
      ],
      child: const TribhubanCustomerApp(),
    ),
  );
}
