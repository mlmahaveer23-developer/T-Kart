import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/coupon.dart';
import '../repositories/rewards_repository.dart';

class GetCouponsUseCase {
  const GetCouponsUseCase(this._repository);

  final RewardsRepository _repository;

  Future<Either<Failure, List<Coupon>>> call() => _repository.getCoupons();
}
