import '../../domain/entities/referral_info.dart';

class ReferralInfoModel extends ReferralInfo {
  const ReferralInfoModel({
    required super.code,
    required super.referredCount,
    required super.totalRewardEarnedRupees,
    required super.hasRedeemedACode,
  });
}
