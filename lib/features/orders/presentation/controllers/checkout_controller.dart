import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../../address/domain/entities/address.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/place_order_input.dart';
import 'order_providers.dart';

/// Drives the checkout screen's "Place Order" action. Converts the
/// current cart + a chosen [Address] into a [PlaceOrderInput], submits
/// it, and — only on success — clears the cart. Keeping the clear
/// inside this controller (rather than the screen) means the cart can
/// never be wiped on a failed order.
class CheckoutController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Order?> placeOrder({
    required Address address,
    required List<CartItem> cartItems,
    String? couponCode,
  }) async {
    state = const AsyncLoading<void>();

    final List<OrderItem> orderItems = cartItems
        .map((CartItem c) => OrderItem(
              bundleId: c.bundleId,
              bundleName: c.name,
              priceRupees: c.priceRupees,
              rewardValueRupees: c.rewardValueRupees,
              quantity: c.quantity,
            ))
        .toList();

    final PlaceOrderInput input = PlaceOrderInput(
      recipientName: address.recipientName,
      phone: address.phone,
      addressLine1: address.line1,
      addressLine2: address.line2,
      city: address.city,
      state: address.state,
      pincode: address.pincode,
      items: orderItems,
      couponCode: couponCode,
    );

    final result = await ref.read(placeOrderUseCaseProvider).call(input);

    Order? placedOrder;
    result.fold(
      (Failure failure) {
        state = AsyncError<void>(failure, StackTrace.current);
      },
      (Order order) {
        placedOrder = order;
      },
    );

    if (placedOrder != null) {
      state = const AsyncData<void>(null);
      await ref.read(cartControllerProvider.notifier).clear();
    }

    return placedOrder;
  }
}

final AutoDisposeAsyncNotifierProvider<CheckoutController, void>
    checkoutControllerProvider =
    AutoDisposeAsyncNotifierProvider<CheckoutController, void>(
  CheckoutController.new,
);
