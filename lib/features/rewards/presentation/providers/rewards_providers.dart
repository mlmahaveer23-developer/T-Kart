import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/rewards_remote_data_source.dart';
import '../../data/repositories/rewards_repository_impl.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/entities/referral_info.dart';
import '../../domain/entities/reward_transaction.dart';
import '../../domain/repositories/rewards_repository.dart';
import '../../domain/usecases/claim_coupon_usecase.dart';
import '../../domain/usecases/get_claimed_coupon_ids_usecase.dart';
import '../../domain/usecases/get_coupons_usecase.dart';
import '../../domain/usecases/get_referral_info_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/redeem_referral_code_usecase.dart';

final Provider<RewardsRemoteDataSource> rewardsRemoteDataSourceProvider =
    Provider<RewardsRemoteDataSource>(
  (Ref ref) => RewardsRemoteDataSourceImpl(ref.watch(supabaseClientProvider)),
);

final Provider<RewardsRepository> rewardsRepositoryProvider =
    Provider<RewardsRepository>(
  (Ref ref) => RewardsRepositoryImpl(
    remoteDataSource: ref.watch(rewardsRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final Provider<GetTransactionsUseCase> getTransactionsUseCaseProvider =
    Provider<GetTransactionsUseCase>(
  (Ref ref) => GetTransactionsUseCase(ref.watch(rewardsRepositoryProvider)),
);

final Provider<GetCouponsUseCase> getCouponsUseCaseProvider =
    Provider<GetCouponsUseCase>(
  (Ref ref) => GetCouponsUseCase(ref.watch(rewardsRepositoryProvider)),
);

final Provider<GetClaimedCouponIdsUseCase> getClaimedCouponIdsUseCaseProvider =
    Provider<GetClaimedCouponIdsUseCase>(
  (Ref ref) => GetClaimedCouponIdsUseCase(ref.watch(rewardsRepositoryProvider)),
);

final Provider<ClaimCouponUseCase> claimCouponUseCaseProvider =
    Provider<ClaimCouponUseCase>(
  (Ref ref) => ClaimCouponUseCase(ref.watch(rewardsRepositoryProvider)),
);

final Provider<GetReferralInfoUseCase> getReferralInfoUseCaseProvider =
    Provider<GetReferralInfoUseCase>(
  (Ref ref) => GetReferralInfoUseCase(ref.watch(rewardsRepositoryProvider)),
);

final Provider<RedeemReferralCodeUseCase> redeemReferralCodeUseCaseProvider =
    Provider<RedeemReferralCodeUseCase>(
  (Ref ref) => RedeemReferralCodeUseCase(ref.watch(rewardsRepositoryProvider)),
);

final FutureProvider<List<RewardTransaction>> rewardTransactionsProvider =
    FutureProvider<List<RewardTransaction>>((Ref ref) async {
  final result = await ref.watch(getTransactionsUseCaseProvider).call();
  return result.fold((failure) => throw failure, (transactions) => transactions);
});

/// Derived wallet balance — sum of signed transaction amounts. See
/// [RewardTransaction.signedAmountRupees].
final Provider<int> rewardBalanceRupeesProvider = Provider<int>((Ref ref) {
  final List<RewardTransaction> transactions =
      ref.watch(rewardTransactionsProvider).valueOrNull ?? const <RewardTransaction>[];
  return transactions.fold<int>(
    0,
    (int sum, RewardTransaction t) => sum + t.signedAmountRupees,
  );
});

final FutureProvider<List<Coupon>> couponsProvider =
    FutureProvider<List<Coupon>>((Ref ref) async {
  final result = await ref.watch(getCouponsUseCaseProvider).call();
  return result.fold((failure) => throw failure, (coupons) => coupons);
});

final FutureProvider<List<String>> claimedCouponIdsProvider =
    FutureProvider<List<String>>((Ref ref) async {
  final result = await ref.watch(getClaimedCouponIdsUseCaseProvider).call();
  return result.fold((failure) => throw failure, (ids) => ids);
});

final FutureProvider<ReferralInfo> referralInfoProvider =
    FutureProvider<ReferralInfo>((Ref ref) async {
  final result = await ref.watch(getReferralInfoUseCaseProvider).call();
  return result.fold((failure) => throw failure, (info) => info);
});
