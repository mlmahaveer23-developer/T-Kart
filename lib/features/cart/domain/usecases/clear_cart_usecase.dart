import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase {
  const ClearCartUseCase(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, List<CartItem>>> call() => _repository.clearCart();
}
