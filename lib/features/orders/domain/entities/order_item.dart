import 'package:equatable/equatable.dart';

/// A line item within a placed order — a snapshot of the bundle as it
/// was at purchase time, same rationale as CartItem.
class OrderItem extends Equatable {
  const OrderItem({
    required this.bundleName,
    required this.priceRupees,
    required this.rewardValueRupees,
    required this.quantity,
    this.bundleId,
  });

  final String? bundleId;
  final String bundleName;
  final int priceRupees;
  final int rewardValueRupees;
  final int quantity;

  int get lineTotalRupees => priceRupees * quantity;

  @override
  List<Object?> get props =>
      <Object?>[bundleId, bundleName, priceRupees, rewardValueRupees, quantity];
}
