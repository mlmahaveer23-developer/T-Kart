import 'package:equatable/equatable.dart';

/// A cart line item. Deliberately stores a *snapshot* of the bundle's
/// display data (name/price/reward/image) at the moment it was added,
/// rather than just a `bundleId` — this is standard e-commerce practice:
/// the cart shows what the customer saw when they added it, stays
/// intact even if the bundle is later renamed/removed from the catalog,
/// and needs no extra network round-trip to render. The real, current
/// price is re-validated server-side at checkout (Phase 5) regardless.
class CartItem extends Equatable {
  const CartItem({
    required this.bundleId,
    required this.name,
    required this.priceRupees,
    required this.rewardValueRupees,
    required this.quantity,
    this.imageUrl,
  });

  final String bundleId;
  final String name;
  final int priceRupees;
  final int rewardValueRupees;
  final int quantity;
  final String? imageUrl;

  int get lineTotalRupees => priceRupees * quantity;
  int get lineRewardRupees => rewardValueRupees * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      bundleId: bundleId,
      name: name,
      priceRupees: priceRupees,
      rewardValueRupees: rewardValueRupees,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[bundleId, name, priceRupees, rewardValueRupees, quantity, imageUrl];
}
