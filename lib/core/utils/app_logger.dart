import 'package:logger/logger.dart';

/// Single logging entry point. Swapping the sink (e.g. to Crashlytics or
/// Sentry in production) happens here only — nowhere else in the app
/// should import `package:logger` directly.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void debug(String message) => _logger.d(message);
  static void info(String message) => _logger.i(message);
  static void warning(String message) => _logger.w(message);
  static void error(String message, [Object? error, StackTrace? stack]) =>
      _logger.e(message, error: error, stackTrace: stack);
}
