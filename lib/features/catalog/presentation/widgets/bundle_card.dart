import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/bundle.dart';

final NumberFormat _rupeeFormat =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

/// Catalog card for a single bundle. Used in both the featured
/// horizontal carousel and the main grid — sizing adapts via [width].
class BundleCard extends StatelessWidget {
  const BundleCard({
    required this.bundle,
    super.key,
    this.onTap,
    this.width,
  });

  final Bundle bundle;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 4 / 3,
              child: _BundleImage(imageUrl: bundle.imageUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    bundle.name,
                    style: text.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _rupeeFormat.format(bundle.priceRupees),
                    style: text.titleMedium?.copyWith(color: scheme.primary),
                  ),
                  if (bundle.hasReward) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: AppRadius.borderPill,
                      ),
                      child: Text(
                        '+${_rupeeFormat.format(bundle.rewardValueRupees)} reward',
                        style: text.labelSmall?.copyWith(
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BundleImage extends StatelessWidget {
  const _BundleImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(
          Icons.inventory_2_outlined,
          size: 36,
          color: scheme.outline,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (BuildContext context, String url) => const SkeletonBox(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.zero,
      ),
      errorWidget: (BuildContext context, String url, Object error) => Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.broken_image_outlined, color: scheme.outline),
      ),
    );
  }
}
