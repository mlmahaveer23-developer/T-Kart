import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/rewards_repository.dart';

class ClaimCouponUseCase {
  const ClaimCouponUseCase(this._repository);

  final RewardsRepository _repository;

  Future<Either<Failure, void>> call(String couponId) =>
      _repository.claimCoupon(couponId);
}
