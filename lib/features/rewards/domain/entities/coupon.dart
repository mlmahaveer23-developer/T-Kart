import 'package:equatable/equatable.dart';

class Coupon extends Equatable {
  const Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountRupees,
    required this.minOrderRupees,
    required this.isActive,
    this.expiresAt,
  });

  final String id;
  final String code;
  final String description;
  final int discountRupees;
  final int minOrderRupees;
  final bool isActive;
  final DateTime? expiresAt;

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  @override
  List<Object?> get props => <Object?>[
        id,
        code,
        description,
        discountRupees,
        minOrderRupees,
        isActive,
        expiresAt,
      ];
}
