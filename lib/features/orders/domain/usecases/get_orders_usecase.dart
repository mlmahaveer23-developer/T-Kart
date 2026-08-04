import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  const GetOrdersUseCase(this._repository);

  final OrderRepository _repository;

  Future<Either<Failure, List<Order>>> call() => _repository.getOrders();
}
