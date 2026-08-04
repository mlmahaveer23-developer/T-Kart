import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/address.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    required this.address,
    super.key,
    this.onTap,
    this.selected = false,
    this.trailing,
  });

  final Address address;
  final VoidCallback? onTap;
  final bool selected;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? scheme.primary : scheme.outline,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: AppRadius.borderPill,
                      ),
                      child: Text(
                        address.label,
                        style: text.labelSmall
                            ?.copyWith(color: scheme.onPrimaryContainer),
                      ),
                    ),
                    if (address.isDefault) ...<Widget>[
                      const SizedBox(width: AppSpacing.sm),
                      Text('Default', style: text.labelSmall?.copyWith(color: scheme.secondary)),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(address.recipientName, style: text.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  address.formatted,
                  style: text.bodySmall
                      ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  address.phone,
                  style: text.bodySmall
                      ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
