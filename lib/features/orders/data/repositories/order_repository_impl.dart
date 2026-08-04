import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/place_order_input.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrderRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  final OrderRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return Left<Failure, T>(const NetworkFailure());
    }
    try {
      return Right<Failure, T>(await action());
    } on AuthException catch (e) {
      return Left<Failure, T>(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left<Failure, T>(ServerFailure(e.message));
    } catch (_) {
      return Left<Failure, T>(const UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Order>> placeOrder(PlaceOrderInput input) =>
      _guard(() => _remoteDataSource.placeOrder(input));

  @override
  Future<Either<Failure, List<Order>>> getOrders() =>
      _guard(_remoteDataSource.getOrders);

  @override
  Future<Either<Failure, Order>> getOrderById(String id) =>
      _guard(() => _remoteDataSource.getOrderById(id));
}
