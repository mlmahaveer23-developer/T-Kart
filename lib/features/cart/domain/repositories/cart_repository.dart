import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCart();

  /// Adds [item] to the cart. If a line for the same `bundleId` already
  /// exists, its quantity is incremented by [item.quantity] and its
  /// snapshot data is refreshed to [item]'s values (picks up any price
  /// change since it was first added).
  Future<Either<Failure, List<CartItem>>> addToCart(CartItem item);

  /// Sets the quantity for [bundleId] directly (used by the cart
  /// screen's stepper). A quantity of 0 removes the line.
  Future<Either<Failure, List<CartItem>>> setQuantity({
    required String bundleId,
    required int quantity,
  });

  Future<Either<Failure, List<CartItem>>> removeFromCart(String bundleId);

  Future<Either<Failure, List<CartItem>>> clearCart();
}
