import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/exceptions.dart';
import '../models/coupon_model.dart';
import '../models/referral_info_model.dart';
import '../models/reward_transaction_model.dart';

abstract class RewardsRemoteDataSource {
  Future<List<RewardTransactionModel>> getTransactions();
  Future<List<CouponModel>> getCoupons();
  Future<List<String>> getClaimedCouponIds();
  Future<void> claimCoupon(String couponId);
  Future<ReferralInfoModel> getReferralInfo();
  Future<void> redeemReferralCode(String code);
}

class RewardsRemoteDataSourceImpl implements RewardsRemoteDataSource {
  RewardsRemoteDataSourceImpl(this._client);

  final supabase.SupabaseClient _client;

  String get _userId {
    final String? id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const AuthException('You need to be signed in to do that.');
    }
    return id;
  }

  Future<T> _guard<T>(Future<T> Function() action, String fallbackMessage) async {
    try {
      return await action();
    } on AuthException {
      rethrow;
    } on supabase.PostgrestException catch (e) {
      // RPC-raised exceptions (e.g. "That referral code was not found.")
      // surface here with a usable message — pass it through rather
      // than flattening it to a generic fallback.
      throw ServerException(e.message);
    } catch (_) {
      throw ServerException(fallbackMessage);
    }
  }

  @override
  Future<List<RewardTransactionModel>> getTransactions() {
    return _guard(() async {
      final List<Map<String, dynamic>> rows = await _client
          .from('reward_transactions')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);
      return rows.map(RewardTransactionModel.fromJson).toList();
    }, 'Could not load your reward history.');
  }

  @override
  Future<List<CouponModel>> getCoupons() {
    return _guard(() async {
      final List<Map<String, dynamic>> rows = await _client
          .from('coupons')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return rows.map(CouponModel.fromJson).toList();
    }, 'Could not load coupons.');
  }

  @override
  Future<List<String>> getClaimedCouponIds() {
    return _guard(() async {
      final List<Map<String, dynamic>> rows = await _client
          .from('coupon_redemptions')
          .select('coupon_id')
          .eq('user_id', _userId);
      return rows.map((Map<String, dynamic> r) => r['coupon_id'] as String).toList();
    }, 'Could not load your coupons.');
  }

  @override
  Future<void> claimCoupon(String couponId) {
    return _guard(() async {
      await _client.from('coupon_redemptions').insert(<String, dynamic>{
        'user_id': _userId,
        'coupon_id': couponId,
      });
    }, 'Could not claim this coupon — you may have already claimed it.');
  }

  @override
  Future<ReferralInfoModel> getReferralInfo() {
    return _guard(() async {
      final Map<String, dynamic> referralRow = await _client
          .from('referrals')
          .select('code')
          .eq('user_id', _userId)
          .single();

      final List<Map<String, dynamic>> redemptions = await _client
          .from('referral_redemptions')
          .select('reward_rupees')
          .eq('referrer_id', _userId);

      final List<Map<String, dynamic>> ownRedemption = await _client
          .from('referral_redemptions')
          .select('id')
          .eq('referee_id', _userId);

      final int totalEarned = redemptions.fold<int>(
        0,
        (int sum, Map<String, dynamic> r) => sum + (r['reward_rupees'] as int),
      );

      return ReferralInfoModel(
        code: referralRow['code'] as String,
        referredCount: redemptions.length,
        totalRewardEarnedRupees: totalEarned,
        hasRedeemedACode: ownRedemption.isNotEmpty,
      );
    }, 'Could not load your referral details.');
  }

  @override
  Future<void> redeemReferralCode(String code) {
    return _guard(() async {
      await _client.rpc<void>('redeem_referral_code', params: <String, dynamic>{
        'p_code': code.trim().toUpperCase(),
      });
    }, 'Could not redeem this referral code.');
  }
}
