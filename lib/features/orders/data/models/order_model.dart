import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_status.dart';
import 'order_item_model.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.status,
    required super.subtotalRupees,
    required super.rewardValueRupees,
    required super.recipientName,
    required super.phone,
    required super.addressLine1,
    required super.city,
    required super.state,
    required super.pincode,
    required super.createdAt,
    required super.items,
    super.addressLine2,
    super.discountRupees,
    super.couponCode,
  });

  /// [itemRows] are the corresponding `order_items` rows, fetched
  /// separately (see datasource) and passed in already-decoded.
  factory OrderModel.fromJson(
    Map<String, dynamic> json, {
    List<Map<String, dynamic>> itemRows = const <Map<String, dynamic>>[],
  }) {
    return OrderModel(
      id: json['id'] as String,
      status: OrderStatus.fromString(json['status'] as String),
      subtotalRupees: json['subtotal_rupees'] as int,
      discountRupees: (json['discount_rupees'] as int?) ?? 0,
      couponCode: json['coupon_code'] as String?,
      rewardValueRupees: (json['reward_value_rupees'] as int?) ?? 0,
      recipientName: json['recipient_name'] as String,
      phone: json['phone'] as String,
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: itemRows.map(OrderItemModel.fromJson).toList(),
    );
  }
}
