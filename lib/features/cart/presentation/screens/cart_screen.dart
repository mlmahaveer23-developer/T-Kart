import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/cart_item.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_line_item.dart';

final NumberFormat _rupeeFormat =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CartItem>> cartAsync = ref.watch(cartControllerProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cartAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: 3,
          itemBuilder: (BuildContext context, int index) => const SkeletonListTile(),
        ),
        error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
          failure: error is Failure ? error : const UnexpectedFailure(),
          onRetry: () => ref.invalidate(cartControllerProvider),
        ),
        data: (List<CartItem> items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Browse bundles and add one to get started.',
            );
          }
          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (BuildContext context, int index) =>
                      CartLineItem(item: items[index]),
                ),
              ),
              _OrderSummaryBar(items: items),
            ],
          );
        },
      ),
    );
  }
}

class _OrderSummaryBar extends ConsumerWidget {
  const _OrderSummaryBar({required this.items});

  final List<CartItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    final int subtotal = ref.watch(cartSubtotalRupeesProvider);
    final int totalReward = ref.watch(cartTotalRewardRupeesProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (totalReward > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Rewards included', style: text.bodyMedium),
                      Text(
                        '+${_rupeeFormat.format(totalReward)}',
                        style: text.bodyMedium?.copyWith(color: scheme.secondary),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Subtotal', style: text.titleMedium),
                  Text(_rupeeFormat.format(subtotal), style: text.titleLarge),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Proceed to Checkout',
                onPressed: () => context.push(RouteNames.checkout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
