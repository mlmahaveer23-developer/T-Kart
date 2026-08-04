import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/place_order_usecase.dart';

final Provider<OrderRemoteDataSource> orderRemoteDataSourceProvider =
    Provider<OrderRemoteDataSource>(
  (Ref ref) => OrderRemoteDataSourceImpl(ref.watch(supabaseClientProvider)),
);

final Provider<OrderRepository> orderRepositoryProvider = Provider<OrderRepository>(
  (Ref ref) => OrderRepositoryImpl(
    remoteDataSource: ref.watch(orderRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  ),
);

final Provider<PlaceOrderUseCase> placeOrderUseCaseProvider =
    Provider<PlaceOrderUseCase>(
  (Ref ref) => PlaceOrderUseCase(ref.watch(orderRepositoryProvider)),
);

final Provider<GetOrdersUseCase> getOrdersUseCaseProvider =
    Provider<GetOrdersUseCase>(
  (Ref ref) => GetOrdersUseCase(ref.watch(orderRepositoryProvider)),
);

final Provider<GetOrderByIdUseCase> getOrderByIdUseCaseProvider =
    Provider<GetOrderByIdUseCase>(
  (Ref ref) => GetOrderByIdUseCase(ref.watch(orderRepositoryProvider)),
);

final FutureProvider<List<Order>> ordersProvider = FutureProvider<List<Order>>(
  (Ref ref) async {
    final result = await ref.watch(getOrdersUseCaseProvider).call();
    return result.fold((failure) => throw failure, (orders) => orders);
  },
);

final FutureProviderFamily<Order, String> orderByIdProvider =
    FutureProvider.family<Order, String>((Ref ref, String id) async {
  final result = await ref.watch(getOrderByIdUseCaseProvider).call(id);
  return result.fold((failure) => throw failure, (order) => order);
});
