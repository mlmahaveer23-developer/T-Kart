import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.bundleId,
    required super.name,
    required super.priceRupees,
    required super.rewardValueRupees,
    required super.quantity,
    super.imageUrl,
  });

  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(
      bundleId: item.bundleId,
      name: item.name,
      priceRupees: item.priceRupees,
      rewardValueRupees: item.rewardValueRupees,
      quantity: item.quantity,
      imageUrl: item.imageUrl,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      bundleId: json['bundleId'] as String,
      name: json['name'] as String,
      priceRupees: json['priceRupees'] as int,
      rewardValueRupees: (json['rewardValueRupees'] as int?) ?? 0,
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'bundleId': bundleId,
        'name': name,
        'priceRupees': priceRupees,
        'rewardValueRupees': rewardValueRupees,
        'quantity': quantity,
        'imageUrl': imageUrl,
      };
}
