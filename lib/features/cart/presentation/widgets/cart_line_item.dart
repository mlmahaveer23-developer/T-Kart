import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_icon_button.dart';
import '../../domain/entities/cart_item.dart';
import '../controllers/cart_controller.dart';
import 'quantity_stepper.dart';

final NumberFormat _rupeeFormat =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

class CartLineItem extends ConsumerWidget {
  const CartLineItem({required this.item, super.key});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: AppRadius.borderSm,
            child: SizedBox(
              width: 64,
              height: 64,
              child: item.imageUrl == null || item.imageUrl!.isEmpty
                  ? Container(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(Icons.inventory_2_outlined, color: scheme.outline),
                    )
                  : CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.name, style: text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _rupeeFormat.format(item.priceRupees),
                  style: text.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    QuantityStepper(
                      quantity: item.quantity,
                      min: 0,
                      onChanged: (int newQuantity) => ref
                          .read(cartControllerProvider.notifier)
                          .setQuantity(bundleId: item.bundleId, quantity: newQuantity),
                    ),
                    const Spacer(),
                    Text(
                      _rupeeFormat.format(item.lineTotalRupees),
                      style: text.titleSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.close_rounded,
            size: 32,
            iconSize: 16,
            backgroundColor: Colors.transparent,
            onPressed: () => ref.read(cartControllerProvider.notifier).remove(item.bundleId),
          ),
        ],
      ),
    );
  }
}
