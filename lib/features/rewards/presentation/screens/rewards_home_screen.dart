import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/entities/referral_info.dart';
import '../../domain/entities/reward_transaction.dart';
import '../controllers/rewards_actions_controller.dart';
import '../providers/rewards_providers.dart';
import '../widgets/coupon_card.dart';
import '../widgets/wallet_balance_card.dart';

final NumberFormat _rupeeFormat =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final DateFormat _dateFormat = DateFormat('d MMM yyyy');

class RewardsHomeScreen extends StatelessWidget {
  const RewardsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: AppScaffold(
        appBar: AppBar(
          title: const Text('Rewards'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Wallet'),
              Tab(text: 'Coupons'),
              Tab(text: 'Referral'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[_WalletTab(), _CouponsTab(), _ReferralTab()],
        ),
      ),
    );
  }
}

class _WalletTab extends ConsumerWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<RewardTransaction>> transactionsAsync =
        ref.watch(rewardTransactionsProvider);
    final int balance = ref.watch(rewardBalanceRupeesProvider);

    return transactionsAsync.when(
      loading: () => const AppLoadingIndicator(),
      error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
        failure: error is Failure ? error : const UnexpectedFailure(),
        onRetry: () => ref.invalidate(rewardTransactionsProvider),
      ),
      data: (List<RewardTransaction> transactions) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            WalletBalanceCard(balanceRupees: balance),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'History'),
            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'No reward activity yet',
                  message: 'Place an order to start earning rewards.',
                ),
              )
            else
              for (final RewardTransaction t in transactions) _TransactionRow(t: t),
          ],
        );
      },
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.t});

  final RewardTransaction t;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final bool isEarned = t.type == RewardTransactionType.earned;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Icon(
            isEarned ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
            color: isEarned ? scheme.primary : scheme.error,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(t.description, style: text.bodyMedium),
                Text(
                  _dateFormat.format(t.createdAt),
                  style: text.bodySmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          Text(
            '${isEarned ? '+' : ''}${_rupeeFormat.format(t.signedAmountRupees)}',
            style: text.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _CouponsTab extends ConsumerWidget {
  const _CouponsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Coupon>> couponsAsync = ref.watch(couponsProvider);
    final AsyncValue<List<String>> claimedAsync = ref.watch(claimedCouponIdsProvider);

    return couponsAsync.when(
      loading: () => const AppLoadingIndicator(),
      error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
        failure: error is Failure ? error : const UnexpectedFailure(),
        onRetry: () => ref.invalidate(couponsProvider),
      ),
      data: (List<Coupon> coupons) {
        final List<String> claimedIds = claimedAsync.valueOrNull ?? const <String>[];
        final List<Coupon> available = coupons.where((Coupon c) => !c.isExpired).toList();

        if (available.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.local_offer_outlined,
            title: 'No coupons right now',
            message: 'Check back soon for new offers.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: available.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (BuildContext context, int index) {
            final Coupon coupon = available[index];
            final bool claimed = claimedIds.contains(coupon.id);
            return CouponCard(
              coupon: coupon,
              isClaimed: claimed,
              onClaim: claimed ? null : () => _claim(context, ref, coupon.id),
            );
          },
        );
      },
    );
  }

  Future<void> _claim(BuildContext context, WidgetRef ref, String couponId) async {
    final bool success =
        await ref.read(rewardsActionsControllerProvider.notifier).claimCoupon(couponId);
    if (!context.mounted) return;
    if (success) {
      AppSnackbar.success(context, 'Coupon claimed');
    } else {
      AppSnackbar.error(context, 'Could not claim this coupon.');
    }
  }
}

class _ReferralTab extends ConsumerStatefulWidget {
  const _ReferralTab();

  @override
  ConsumerState<_ReferralTab> createState() => _ReferralTabState();
}

class _ReferralTabState extends ConsumerState<_ReferralTab> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final String code = _codeController.text.trim();
    if (code.isEmpty) return;

    final bool success = await ref
        .read(rewardsActionsControllerProvider.notifier)
        .redeemReferralCode(code);

    if (!mounted) return;
    if (success) {
      AppSnackbar.success(context, 'Referral code redeemed — reward added!');
      _codeController.clear();
    } else {
      final Object? error = ref.read(rewardsActionsControllerProvider).error;
      AppSnackbar.error(
        context,
        error is Failure ? error.message : 'Could not redeem that code.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ReferralInfo> referralAsync = ref.watch(referralInfoProvider);
    final bool isRedeeming = ref.watch(rewardsActionsControllerProvider).isLoading;

    return referralAsync.when(
      loading: () => const AppLoadingIndicator(),
      error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
        failure: error is Failure ? error : const UnexpectedFailure(),
        onRetry: () => ref.invalidate(referralInfoProvider),
      ),
      data: (ReferralInfo info) => _ReferralBody(
        info: info,
        codeController: _codeController,
        isRedeeming: isRedeeming,
        onRedeem: _redeem,
      ),
    );
  }
}

class _ReferralBody extends StatelessWidget {
  const _ReferralBody({
    required this.info,
    required this.codeController,
    required this.isRedeeming,
    required this.onRedeem,
  });

  final ReferralInfo info;
  final TextEditingController codeController;
  final bool isRedeeming;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        Text('Your referral code', style: text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          onTap: () {
            Clipboard.setData(ClipboardData(text: info.code));
            AppSnackbar.success(context, 'Code copied to clipboard');
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(info.code, style: text.headlineSmall?.copyWith(letterSpacing: 2)),
              const Icon(Icons.copy_rounded),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: <Widget>[
            Expanded(
              child: _StatCard(label: 'Friends referred', value: '${info.referredCount}'),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'Earned from referrals',
                value: _rupeeFormat.format(info.totalRewardEarnedRupees),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (info.hasRedeemedACode)
          AppCard(
            child: Row(
              children: <Widget>[
                Icon(Icons.check_circle_rounded, color: scheme.primary),
                const SizedBox(width: AppSpacing.md),
                const Expanded(child: Text("You've already redeemed a referral code.")),
              ],
            ),
          )
        else ...<Widget>[
          Text("Have a friend's code?", style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: 'Referral code',
            controller: codeController,
            hintText: 'e.g. AB12CD34',
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Redeem',
            isLoading: isRedeeming,
            onPressed: isRedeeming ? null : onRedeem,
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: text.bodySmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
