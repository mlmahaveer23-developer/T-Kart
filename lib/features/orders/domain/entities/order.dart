import 'package:equatable/equatable.dart';
import 'order_item.dart';
import 'order_status.dart';

class Order extends Equatable {
  const Order({
    required this.id,
    required this.status,
    required this.subtotalRupees,
    required this.rewardValueRupees,
    required this.recipientName,
    required this.phone,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.pincode,
    required this.createdAt,
    required this.items,
    this.addressLine2,
    this.discountRupees = 0,
    this.couponCode,
  });

  final String id;
  final OrderStatus status;
  final int subtotalRupees;
  final int discountRupees;
  final String? couponCode;
  final int rewardValueRupees;
  final String recipientName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final DateTime createdAt;
  final List<OrderItem> items;

  int get totalRupees => subtotalRupees - discountRupees;

  String get formattedAddress =>
      '$addressLine1${addressLine2 == null || addressLine2!.isEmpty ? '' : ', $addressLine2'}, $city, $state $pincode';

  @override
  List<Object?> get props => <Object?>[
        id,
        status,
        subtotalRupees,
        discountRupees,
        couponCode,
        rewardValueRupees,
        recipientName,
        phone,
        addressLine1,
        addressLine2,
        city,
        state,
        pincode,
        createdAt,
        items,
      ];
}
