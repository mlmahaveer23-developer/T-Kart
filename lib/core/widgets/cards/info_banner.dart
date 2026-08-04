import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

enum InfoBannerVariant { reward, info, warning }

/// Gradient highlight banner — the visual language for anything tied to
/// the rewards/coupon/referral system (₹2,500 reward value, coupon
/// unlocks, referral progress), kept visually distinct from ordinary
/// content cards so users learn to recognize "this is a reward" at a
/// glance.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    required this.message,
    super.key,
    this.icon = Icons.card_giftcard_rounded,
    this.variant = InfoBannerVariant.reward,
    this.onTap,
    this.trailing,
  });

  final String message;
  final IconData icon;
  final InfoBannerVariant variant;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<Color> colors = switch (variant) {
      InfoBannerVariant.reward => const <Color>[
          AppColors.rewardGradientStart,
          AppColors.rewardGradientEnd,
        ],
      InfoBannerVariant.info => const <Color>[
          AppColors.forest500,
          AppColors.forest900,
        ],
      InfoBannerVariant.warning => const <Color>[
          AppColors.warning,
          Color(0xFF7A5510),
        ],
    };

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.borderLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.borderLg,
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color: Colors.white),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: text.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
