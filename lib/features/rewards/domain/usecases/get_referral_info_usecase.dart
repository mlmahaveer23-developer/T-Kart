import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/referral_info.dart';
import '../repositories/rewards_repository.dart';

class GetReferralInfoUseCase {
  const GetReferralInfoUseCase(this._repository);

  final RewardsRepository _repository;

  Future<Either<Failure, ReferralInfo>> call() => _repository.getReferralInfo();
}
