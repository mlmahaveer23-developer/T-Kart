import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/cart_local_data_source.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/set_cart_quantity_usecase.dart';

final Provider<CartLocalDataSource> cartLocalDataSourceProvider =
    Provider<CartLocalDataSource>((Ref ref) => CartLocalDataSourceImpl());

final Provider<CartRepository> cartRepositoryProvider = Provider<CartRepository>(
  (Ref ref) =>
      CartRepositoryImpl(localDataSource: ref.watch(cartLocalDataSourceProvider)),
);

final Provider<GetCartUseCase> getCartUseCaseProvider = Provider<GetCartUseCase>(
  (Ref ref) => GetCartUseCase(ref.watch(cartRepositoryProvider)),
);

final Provider<AddToCartUseCase> addToCartUseCaseProvider =
    Provider<AddToCartUseCase>(
  (Ref ref) => AddToCartUseCase(ref.watch(cartRepositoryProvider)),
);

final Provider<SetCartQuantityUseCase> setCartQuantityUseCaseProvider =
    Provider<SetCartQuantityUseCase>(
  (Ref ref) => SetCartQuantityUseCase(ref.watch(cartRepositoryProvider)),
);

final Provider<RemoveFromCartUseCase> removeFromCartUseCaseProvider =
    Provider<RemoveFromCartUseCase>(
  (Ref ref) => RemoveFromCartUseCase(ref.watch(cartRepositoryProvider)),
);

final Provider<ClearCartUseCase> clearCartUseCaseProvider =
    Provider<ClearCartUseCase>(
  (Ref ref) => ClearCartUseCase(ref.watch(cartRepositoryProvider)),
);
