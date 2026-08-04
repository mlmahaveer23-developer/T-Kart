import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/order.dart';
import '../providers/order_providers.dart';
import '../widgets/order_status_badge.dart';

final NumberFormat _rupeeFormat =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final DateFormat _dateFormat = DateFormat('d MMM yyyy, h:mm a');

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Order> orderAsync = ref.watch(orderByIdProvider(orderId));

    return AppScaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: orderAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
          failure: error is Failure ? error : const UnexpectedFailure(),
          onRetry: () => ref.invalidate(orderByIdProvider(orderId)),
        ),
        data: (Order order) => _OrderDetailBody(order: order),
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_dateFormat.format(order.createdAt), style: text.bodyMedium),
            OrderStatusBadge(status: order.status),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        Text('Items', style: text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            children: <Widget>[
              for (int i = 0; i < order.items.length; i++) ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${order.items[i].bundleName} × ${order.items[i].quantity}',
                        style: text.bodyMedium,
                      ),
                    ),
                    Text(_rupeeFormat.format(order.items[i].lineTotalRupees)),
                  ],
                ),
                if (i != order.items.length - 1) const Divider(height: AppSpacing.lg),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        Text('Delivery address', style: text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(order.recipientName, style: text.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                order.formattedAddress,
                style: text.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                order.phone,
                style: text.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        Text('Payment summary', style: text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Subtotal', style: text.bodyMedium),
                  Text(_rupeeFormat.format(order.subtotalRupees)),
                ],
              ),
              if (order.discountRupees > 0) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      order.couponCode == null
                          ? 'Coupon discount'
                          : 'Coupon discount (${order.couponCode})',
                      style: text.bodyMedium,
                    ),
                    Text(
                      '−${_rupeeFormat.format(order.discountRupees)}',
                      style: TextStyle(color: scheme.secondary),
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Total paid', style: text.titleSmall),
                    Text(_rupeeFormat.format(order.totalRupees), style: text.titleSmall),
                  ],
                ),
              ],
              if (order.rewardValueRupees > 0) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Rewards earned', style: text.bodyMedium),
                    Text(
                      '+${_rupeeFormat.format(order.rewardValueRupees)}',
                      style: TextStyle(color: scheme.secondary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
