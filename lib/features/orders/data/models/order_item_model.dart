import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.bundleName,
    required super.priceRupees,
    required super.rewardValueRupees,
    required super.quantity,
    super.bundleId,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      bundleId: json['bundle_id'] as String?,
      bundleName: json['bundle_name'] as String,
      priceRupees: json['price_rupees'] as int,
      rewardValueRupees: (json['reward_value_rupees'] as int?) ?? 0,
      quantity: json['quantity'] as int,
    );
  }

  /// Shape expected by the `place_order()` RPC's `p_items` jsonb array —
  /// see `supabase/migrations/0004_atomic_order_placement.sql`.
  Map<String, dynamic> toRpcJson() => <String, dynamic>{
        'bundle_id': bundleId,
        'bundle_name': bundleName,
        'price_rupees': priceRupees,
        'reward_value_rupees': rewardValueRupees,
        'quantity': quantity,
      };
}
