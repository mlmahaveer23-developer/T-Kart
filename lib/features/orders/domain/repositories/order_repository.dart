import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order.dart';
import '../entities/place_order_input.dart';

abstract class OrderRepository {
  Future<Either<Failure, Order>> placeOrder(PlaceOrderInput input);

  Future<Either<Failure, List<Order>>> getOrders();

  Future<Either<Failure, Order>> getOrderById(String id);
}
