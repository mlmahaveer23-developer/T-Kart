import 'order_item.dart';

/// Input shape for placing an order — grouped as its own small class
/// rather than a long parameter list on the repository method.
class PlaceOrderInput {
  const PlaceOrderInput({
    required this.recipientName,
    required this.phone,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.pincode,
    required this.items,
    this.addressLine2,
    this.couponCode,
  });

  final String recipientName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final List<OrderItem> items;

  /// Must have already been claimed by this user (see
  /// `coupon_redemptions` — enforced server-side in `place_order()`).
  final String? couponCode;
}
