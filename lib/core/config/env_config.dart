import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central, typed access to environment configuration.
///
/// Values are loaded from `.env` at app startup (see `main.dart`) and are
/// NEVER hardcoded in source. `.env` is git-ignored — see `.env.example`
/// for the required keys.
class EnvConfig {
  const EnvConfig._();

  static String get supabaseUrl => _require('SUPABASE_URL');

  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  static AppEnvironment get appEnv {
    final String raw = dotenv.env['APP_ENV']?.toLowerCase() ?? 'development';
    return AppEnvironment.values.firstWhere(
      (AppEnvironment e) => e.name == raw,
      orElse: () => AppEnvironment.development,
    );
  }

  static bool get isProduction => appEnv == AppEnvironment.production;

  static String _require(String key) {
    final String? value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required environment variable "$key". '
        'Copy .env.example to .env and fill in real values.',
      );
    }
    return value;
  }
}

enum AppEnvironment { development, staging, production }
