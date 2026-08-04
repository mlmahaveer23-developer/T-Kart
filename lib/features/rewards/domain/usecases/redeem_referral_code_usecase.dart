import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/rewards_repository.dart';

class RedeemReferralCodeUseCase {
  const RedeemReferralCodeUseCase(this._repository);

  final RewardsRepository _repository;

  Future<Either<Failure, void>> call(String code) =>
      _repository.redeemReferralCode(code);
}
