import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rewards_providers.dart';

/// Handles the two mutating actions in this feature — claiming a
/// coupon and redeeming a referral code. Both invalidate the relevant
/// read providers on success so the UI reflects the change immediately
/// without a manual refresh.
class RewardsActionsController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> claimCoupon(String couponId) async {
    state = const AsyncLoading<void>();
    final result = await ref.read(claimCouponUseCaseProvider).call(couponId);
    return result.fold(
      (failure) {
        state = AsyncError<void>(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData<void>(null);
        ref.invalidate(claimedCouponIdsProvider);
        return true;
      },
    );
  }

  Future<bool> redeemReferralCode(String code) async {
    state = const AsyncLoading<void>();
    final result = await ref.read(redeemReferralCodeUseCaseProvider).call(code);
    return result.fold(
      (failure) {
        state = AsyncError<void>(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData<void>(null);
        ref
          ..invalidate(referralInfoProvider)
          ..invalidate(rewardTransactionsProvider);
        return true;
      },
    );
  }
}

final AutoDisposeAsyncNotifierProvider<RewardsActionsController, void>
    rewardsActionsControllerProvider =
    AutoDisposeAsyncNotifierProvider<RewardsActionsController, void>(
  RewardsActionsController.new,
);
