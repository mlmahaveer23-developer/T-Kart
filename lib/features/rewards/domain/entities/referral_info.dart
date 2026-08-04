import 'package:equatable/equatable.dart';

/// A user's own referral identity plus their aggregate referral stats.
class ReferralInfo extends Equatable {
  const ReferralInfo({
    required this.code,
    required this.referredCount,
    required this.totalRewardEarnedRupees,
    required this.hasRedeemedACode,
  });

  final String code;
  final int referredCount;
  final int totalRewardEarnedRupees;

  /// Whether this user has already redeemed someone else's referral
  /// code — each account can do so at most once (enforced server-side).
  final bool hasRedeemedACode;

  @override
  List<Object?> get props =>
      <Object?>[code, referredCount, totalRewardEarnedRupees, hasRedeemedACode];
}
