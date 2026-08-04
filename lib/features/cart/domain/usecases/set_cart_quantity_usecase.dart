import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class SetCartQuantityUseCase {
  const SetCartQuantityUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, List<CartItem>>> call({
    required String bundleId,
    required int quantity,
  }) =>
      _repository.setQuantity(bundleId: bundleId, quantity: quantity);
}
