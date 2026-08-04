import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../address/domain/entities/address.dart';
import '../../../address/presentation/controllers/address_controller.dart';
import '../../../address/presentation/widgets/address_card.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../rewards/domain/entities/coupon.dart';
import '../../../rewards/presentation/providers/rewards_providers.dart';
import '../../domain/entities/order.dart';
import '../controllers/checkout_controller.dart';

final NumberFormat _rupeeFormat =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddressId;
  String? _selectedCouponId;

  Address? _findAddress(List<Address> addresses, String? id) {
    for (final Address a in addresses) {
      if (a.id == id) return a;
    }
    return null;
  }

  Coupon? _findCoupon(List<Coupon> coupons, String? id) {
    for (final Coupon c in coupons) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> _placeOrder(
    List<CartItem> cartItems,
    List<Address> addresses,
    Coupon? selectedCoupon,
  ) async {
    final Address? selected = _findAddress(addresses, _selectedAddressId);
    if (selected == null) {
      AppSnackbar.error(context, 'Please select a delivery address.');
      return;
    }

    final Order? order = await ref.read(checkoutControllerProvider.notifier).placeOrder(
          address: selected,
          cartItems: cartItems,
          couponCode: selectedCoupon?.code,
        );

    if (!mounted) return;

    if (order != null) {
      context.go('${RouteNames.orderHistory}/${order.id}');
    } else {
      final Object? error = ref.read(checkoutControllerProvider).error;
      AppSnackbar.error(
        context,
        error is Failure ? error.message : 'Could not place your order.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CartItem>> cartAsync = ref.watch(cartControllerProvider);
    final AsyncValue<List<Address>> addressesAsync =
        ref.watch(addressControllerProvider);
    final AsyncValue<List<Coupon>> couponsAsync = ref.watch(couponsProvider);
    final AsyncValue<List<String>> claimedIdsAsync =
        ref.watch(claimedCouponIdsProvider);
    final bool isPlacing = ref.watch(checkoutControllerProvider).isLoading;

    return AppScaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cartAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
          failure: error is Failure ? error : const UnexpectedFailure(),
          onRetry: () => ref.invalidate(cartControllerProvider),
        ),
        data: (List<CartItem> cartItems) {
          if (cartItems.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Add a bundle before checking out.',
            );
          }

          final int subtotal = cartItems.fold<int>(
            0,
            (int sum, CartItem c) => sum + c.lineTotalRupees,
          );

          return addressesAsync.when(
            loading: () => const AppLoadingIndicator(),
            error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
              failure: error is Failure ? error : const UnexpectedFailure(),
              onRetry: () => ref.invalidate(addressControllerProvider),
            ),
            data: (List<Address> addresses) {
              if (_selectedAddressId == null && addresses.isNotEmpty) {
                _selectedAddressId = addresses
                    .firstWhere((Address a) => a.isDefault, orElse: () => addresses.first)
                    .id;
              }

              // Only coupons this user has actually claimed (see the
              // Rewards tab) are offered here — matches the
              // `coupon_redemptions` check enforced server-side in
              // `place_order()`.
              final List<Coupon> allCoupons = couponsAsync.valueOrNull ?? const <Coupon>[];
              final List<String> claimedIds =
                  claimedIdsAsync.valueOrNull ?? const <String>[];
              final List<Coupon> claimedCoupons = allCoupons
                  .where((Coupon c) => claimedIds.contains(c.id) && !c.isExpired)
                  .toList();

              final Coupon? selectedCoupon = _findCoupon(claimedCoupons, _selectedCouponId);
              final bool couponMeetsMinimum =
                  selectedCoupon == null || subtotal >= selectedCoupon.minOrderRupees;
              final int discount = (selectedCoupon != null && couponMeetsMinimum)
                  ? (selectedCoupon.discountRupees < subtotal
                      ? selectedCoupon.discountRupees
                      : subtotal)
                  : 0;
              final int total = subtotal - discount;

              return Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: <Widget>[
                        SectionHeader(
                          title: 'Delivery address',
                          actionLabel: 'Add new',
                          onAction: () => context.push(RouteNames.addressForm),
                        ),
                        if (addresses.isEmpty)
                          EmptyStateWidget(
                            icon: Icons.location_on_outlined,
                            title: 'No saved addresses',
                            message: 'Add one to continue.',
                            actionLabel: 'Add address',
                            onAction: () => context.push(RouteNames.addressForm),
                          )
                        else
                          for (final Address address in addresses)
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: AddressCard(
                                address: address,
                                selected: _selectedAddressId == address.id,
                                onTap: () =>
                                    setState(() => _selectedAddressId = address.id),
                              ),
                            ),

                        const SizedBox(height: AppSpacing.lg),
                        const SectionHeader(title: 'Coupon'),
                        if (claimedCoupons.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            child: Text(
                              'No claimed coupons yet — claim one from the Rewards tab.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          )
                        else
                          _CouponSelector(
                            coupons: claimedCoupons,
                            selectedId: _selectedCouponId,
                            subtotal: subtotal,
                            onSelected: (String? id) =>
                                setState(() => _selectedCouponId = id),
                          ),

                        const SizedBox(height: AppSpacing.lg),
                        const SectionHeader(title: 'Order summary'),
                        for (final CartItem item in cartItems)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    '${item.name} × ${item.quantity}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                Text(_rupeeFormat.format(item.lineTotalRupees)),
                              ],
                            ),
                          ),
                        if (discount > 0) ...<Widget>[
                          const Divider(height: AppSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Coupon discount (${selectedCoupon!.code})',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '−${_rupeeFormat.format(discount)}',
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  _CheckoutBar(
                    subtotal: subtotal,
                    discount: discount,
                    total: total,
                    isPlacing: isPlacing,
                    onPlaceOrder: () => _placeOrder(
                      cartItems,
                      addresses,
                      discount > 0 ? selectedCoupon : null,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CouponSelector extends StatelessWidget {
  const _CouponSelector({
    required this.coupons,
    required this.selectedId,
    required this.subtotal,
    required this.onSelected,
  });

  final List<Coupon> coupons;
  final String? selectedId;
  final int subtotal;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        RadioListTile<String?>(
          contentPadding: EdgeInsets.zero,
          title: const Text('No coupon'),
          value: null,
          // ignore: deprecated_member_use
          groupValue: selectedId,
          onChanged: onSelected,
        ),
        for (final Coupon coupon in coupons)
          RadioListTile<String?>(
            contentPadding: EdgeInsets.zero,
            value: coupon.id,
            // ignore: deprecated_member_use
            groupValue: selectedId,
            onChanged: subtotal >= coupon.minOrderRupees ? onSelected : null,
            title: Text('${coupon.code} — ${coupon.description}'),
            subtitle: subtotal < coupon.minOrderRupees
                ? Text(
                    'Needs a minimum order of ${_rupeeFormat.format(coupon.minOrderRupees)}',
                    style: text.bodySmall?.copyWith(color: scheme.error),
                  )
                : null,
          ),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.isPlacing,
    required this.onPlaceOrder,
  });

  final int subtotal;
  final int discount;
  final int total;
  final bool isPlacing;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Total', style: text.bodySmall),
                    Text(_rupeeFormat.format(total), style: text.titleLarge),
                    if (discount > 0)
                      Text(
                        _rupeeFormat.format(subtotal),
                        style: text.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppButton(
                  label: 'Place Order',
                  isLoading: isPlacing,
                  onPressed: isPlacing ? null : onPlaceOrder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
