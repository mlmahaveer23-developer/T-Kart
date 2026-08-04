import '../../domain/entities/coupon.dart';

class CouponModel extends Coupon {
  const CouponModel({
    required super.id,
    required super.code,
    required super.description,
    required super.discountRupees,
    required super.minOrderRupees,
    required super.isActive,
    super.expiresAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      discountRupees: json['discount_rupees'] as int,
      minOrderRupees: (json['min_order_rupees'] as int?) ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );
  }
}
