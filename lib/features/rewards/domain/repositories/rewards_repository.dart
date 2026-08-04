import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/coupon.dart';
import '../entities/referral_info.dart';
import '../entities/reward_transaction.dart';

abstract class RewardsRepository {
  Future<Either<Failure, List<RewardTransaction>>> getTransactions();

  Future<Either<Failure, List<Coupon>>> getCoupons();

  /// IDs of coupons this user has already claimed.
  Future<Either<Failure, List<String>>> getClaimedCouponIds();

  Future<Either<Failure, void>> claimCoupon(String couponId);

  Future<Either<Failure, ReferralInfo>> getReferralInfo();

  Future<Either<Failure, void>> redeemReferralCode(String code);
}
