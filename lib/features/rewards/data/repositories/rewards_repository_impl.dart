import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/entities/referral_info.dart';
import '../../domain/entities/reward_transaction.dart';
import '../../domain/repositories/rewards_repository.dart';
import '../datasources/rewards_remote_data_source.dart';

class RewardsRepositoryImpl implements RewardsRepository {
  RewardsRepositoryImpl({
    required RewardsRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final RewardsRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return Left<Failure, T>(const NetworkFailure());
    }
    try {
      return Right<Failure, T>(await action());
    } on AuthException catch (e) {
      return Left<Failure, T>(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left<Failure, T>(ServerFailure(e.message));
    } catch (_) {
      return Left<Failure, T>(const UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<RewardTransaction>>> getTransactions() =>
      _guard(_remoteDataSource.getTransactions);

  @override
  Future<Either<Failure, List<Coupon>>> getCoupons() =>
      _guard(_remoteDataSource.getCoupons);

  @override
  Future<Either<Failure, List<String>>> getClaimedCouponIds() =>
      _guard(_remoteDataSource.getClaimedCouponIds);

  @override
  Future<Either<Failure, void>> claimCoupon(String couponId) =>
      _guard(() => _remoteDataSource.claimCoupon(couponId));

  @override
  Future<Either<Failure, ReferralInfo>> getReferralInfo() =>
      _guard(_remoteDataSource.getReferralInfo);

  @override
  Future<Either<Failure, void>> redeemReferralCode(String code) =>
      _guard(() => _remoteDataSource.redeemReferralCode(code));
}
