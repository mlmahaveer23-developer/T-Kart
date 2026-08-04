import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../entities/place_order_input.dart';
import '../repositories/order_repository.dart';

class PlaceOrderUseCase {
  const PlaceOrderUseCase(this._repository);

  final OrderRepository _repository;

  Future<Either<Failure, Order>> call(PlaceOrderInput input) =>
      _repository.placeOrder(input);
}
