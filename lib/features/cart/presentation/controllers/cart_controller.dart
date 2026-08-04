import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_providers.dart';

/// Holds the live cart as an `AsyncNotifier<List<CartItem>>`. All
/// mutating methods call through the repository (which persists to
/// SharedPreferences) and then adopt its returned list as the new
/// state — the repository is the single source of truth, this
/// controller just exposes it reactively to the UI.
class CartController extends AsyncNotifier<List<CartItem>> {
  @override
  FutureOr<List<CartItem>> build() async {
    final result = await ref.read(getCartUseCaseProvider).call();
    return result.fold((failure) => throw failure, (items) => items);
  }

  Future<void> addToCart(CartItem item) async {
    final result = await ref.read(addToCartUseCaseProvider).call(item);
    state = result.fold(
      (failure) => AsyncError<List<CartItem>>(failure, StackTrace.current),
      (items) => AsyncData<List<CartItem>>(items),
    );
  }

  Future<void> setQuantity({required String bundleId, required int quantity}) async {
    final result = await ref
        .read(setCartQuantityUseCaseProvider)
        .call(bundleId: bundleId, quantity: quantity);
    state = result.fold(
      (failure) => AsyncError<List<CartItem>>(failure, StackTrace.current),
      (items) => AsyncData<List<CartItem>>(items),
    );
  }

  Future<void> remove(String bundleId) async {
    final result = await ref.read(removeFromCartUseCaseProvider).call(bundleId);
    state = result.fold(
      (failure) => AsyncError<List<CartItem>>(failure, StackTrace.current),
      (items) => AsyncData<List<CartItem>>(items),
    );
  }

  Future<void> clear() async {
    final result = await ref.read(clearCartUseCaseProvider).call();
    state = result.fold(
      (failure) => AsyncError<List<CartItem>>(failure, StackTrace.current),
      (items) => AsyncData<List<CartItem>>(items),
    );
  }
}

final AsyncNotifierProvider<CartController, List<CartItem>> cartControllerProvider =
    AsyncNotifierProvider<CartController, List<CartItem>>(CartController.new);

/// Total item count across all lines — drives the Home screen's cart
/// badge without every consumer re-deriving it.
final Provider<int> cartItemCountProvider = Provider<int>((Ref ref) {
  final List<CartItem> items = ref.watch(cartControllerProvider).valueOrNull ?? const <CartItem>[];
  return items.fold<int>(0, (int sum, CartItem item) => sum + item.quantity);
});

final Provider<int> cartSubtotalRupeesProvider = Provider<int>((Ref ref) {
  final List<CartItem> items = ref.watch(cartControllerProvider).valueOrNull ?? const <CartItem>[];
  return items.fold<int>(0, (int sum, CartItem item) => sum + item.lineTotalRupees);
});

final Provider<int> cartTotalRewardRupeesProvider = Provider<int>((Ref ref) {
  final List<CartItem> items = ref.watch(cartControllerProvider).valueOrNull ?? const <CartItem>[];
  return items.fold<int>(0, (int sum, CartItem item) => sum + item.lineRewardRupees);
});
