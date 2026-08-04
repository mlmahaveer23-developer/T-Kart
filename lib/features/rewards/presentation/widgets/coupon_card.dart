import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/coupon.dart';

class CouponCard extends StatelessWidget {
  const CouponCard({
    required this.coupon,
    super.key,
    this.isClaimed = false,
    this.onClaim,
  });

  final Coupon coupon;
  final bool isClaimed;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return AppCard(
      child: Row(
        children: <Widget>[
          Icon(Icons.local_offer_rounded, color: scheme.secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(coupon.code, style: text.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  coupon.description,
                  style: text.bodySmall
                      ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
                ),
                if (coupon.minOrderRupees > 0) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Min. order ₹${coupon.minOrderRupees}',
                    style: text.labelSmall
                        ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (isClaimed)
            Icon(Icons.check_circle_rounded, color: scheme.primary)
          else
            AppButton(
              label: 'Claim',
              size: AppButtonSize.small,
              expand: false,
              onPressed: onClaim,
            ),
        ],
      ),
    );
  }
}
