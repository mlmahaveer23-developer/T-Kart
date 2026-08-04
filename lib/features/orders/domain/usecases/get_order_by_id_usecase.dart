import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdUseCase {
  const GetOrderByIdUseCase(this._repository);

  final OrderRepository _repository;

  Future<Either<Failure, Order>> call(String id) => _repository.getOrderById(id);
}
