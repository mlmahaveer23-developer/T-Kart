import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/rewards_repository.dart';

class GetClaimedCouponIdsUseCase {
  const GetClaimedCouponIdsUseCase(this._repository);

  final RewardsRepository _repository;

  Future<Either<Failure, List<String>>> call() => _repository.getClaimedCouponIds();
}
