/// Exceptions are thrown at the data-source boundary (Supabase calls,
/// local cache, network) and are caught by repositories, which convert
/// them into [Failure]s (see failures.dart) for the domain/presentation
/// layers to consume. Presentation code should never catch a raw
/// exception type — only ever deal with Failures via Either.

class ServerException implements Exception {
  const ServerException([this.message = 'Something went wrong on our end.']);
  final String message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection.']);
  final String message;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Local data could not be read.']);
  final String message;
}

class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;
}

class UnexpectedException implements Exception {
  const UnexpectedException([this.message = 'An unexpected error occurred.']);
  final String message;
}
