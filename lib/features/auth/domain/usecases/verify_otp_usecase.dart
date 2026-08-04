import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AppUser>> call({
    required String phone,
    required String otp,
  }) {
    return _repository.verifyOtp(phone: phone, otp: otp);
  }
}
