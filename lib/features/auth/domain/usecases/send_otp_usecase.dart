import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

/// Single-responsibility use case — keeps controllers free of direct
/// repository wiring and gives each business action an independently
/// testable unit.
class SendOtpUseCase {
  const SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, void>> call({required String phone}) {
    return _repository.sendOtp(phone: phone);
  }
}
