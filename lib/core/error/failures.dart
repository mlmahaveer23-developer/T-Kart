import 'package:equatable/equatable.dart';

/// Domain-facing error type. Repositories return `Either<Failure, T>`
/// (via dartz) instead of throwing — this keeps failure handling explicit
/// and testable all the way up to the UI, where a [Failure] maps to a
/// specific empty/error state widget rather than a generic try/catch.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on our end.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data could not be read.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}
