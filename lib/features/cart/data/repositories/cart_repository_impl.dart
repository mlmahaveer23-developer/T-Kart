import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required CartLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final CartLocalDataSource _localDataSource;

  Future<Either<Failure, List<CartItem>>> _guard(
    Future<List<CartItemModel>> Function() action,
  ) async {
    try {
      return Right<Failure, List<CartItem>>(await action());
    } on CacheException catch (e) {
      return Left<Failure, List<CartItem>>(CacheFailure(e.message));
    } catch (_) {
      return const Left<Failure, List<CartItem>>(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> getCart() =>
      _guard(_localDataSource.getItems);

  @override
  Future<Either<Failure, List<CartItem>>> addToCart(CartItem item) {
    return _guard(() async {
      final List<CartItemModel> current = await _localDataSource.getItems();
      final int existingIndex =
          current.indexWhere((CartItemModel e) => e.bundleId == item.bundleId);

      if (existingIndex >= 0) {
        current[existingIndex] = CartItemModel.fromEntity(
          item.copyWith(
            quantity: current[existingIndex].quantity + item.quantity,
          ),
        );
      } else {
        current.add(CartItemModel.fromEntity(item));
      }

      await _localDataSource.saveItems(current);
      return current;
    });
  }

  @override
  Future<Either<Failure, List<CartItem>>> setQuantity({
    required String bundleId,
    required int quantity,
  }) {
    return _guard(() async {
      final List<CartItemModel> current = await _localDataSource.getItems();
      if (quantity <= 0) {
        current.removeWhere((CartItemModel e) => e.bundleId == bundleId);
      } else {
        final int index =
            current.indexWhere((CartItemModel e) => e.bundleId == bundleId);
        if (index >= 0) {
          current[index] =
              CartItemModel.fromEntity(current[index].copyWith(quantity: quantity));
        }
      }
      await _localDataSource.saveItems(current);
      return current;
    });
  }

  @override
  Future<Either<Failure, List<CartItem>>> removeFromCart(String bundleId) {
    return _guard(() async {
      final List<CartItemModel> current = await _localDataSource.getItems();
      current.removeWhere((CartItemModel e) => e.bundleId == bundleId);
      await _localDataSource.saveItems(current);
      return current;
    });
  }

  @override
  Future<Either<Failure, List<CartItem>>> clearCart() {
    return _guard(() async {
      await _localDataSource.saveItems(const <CartItemModel>[]);
      return const <CartItemModel>[];
    });
  }
}
