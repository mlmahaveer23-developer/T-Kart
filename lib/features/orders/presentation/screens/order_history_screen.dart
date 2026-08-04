import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/order.dart';
import '../providers/order_providers.dart';
import '../widgets/order_status_badge.dart';

final NumberFormat _rupeeFormat =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final DateFormat _dateFormat = DateFormat('d MMM yyyy, h:mm a');

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Order>> ordersAsync = ref.watch(ordersProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ordersProvider);
          await ref.read(ordersProvider.future);
        },
        child: ordersAsync.when(
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) => const SkeletonListTile(),
          ),
          error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
            failure: error is Failure ? error : const UnexpectedFailure(),
            onRetry: () => ref.invalidate(ordersProvider),
          ),
          data: (List<Order> orders) {
            if (orders.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                message: 'Your placed orders will show up here.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (BuildContext context, int index) {
                final Order order = orders[index];
                final int itemCount =
                    order.items.fold<int>(0, (int sum, item) => sum + item.quantity);

                return AppCard(
                  onTap: () => context.push('${RouteNames.orderHistory}/${order.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _dateFormat.format(order.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '$itemCount item${itemCount == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _rupeeFormat.format(order.totalRupees),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
