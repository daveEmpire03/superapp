import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/cart_entity.dart';

final cartControllerProvider =
    AsyncNotifierProvider<CartController, CartEntity>(CartController.new);

class CartController extends AsyncNotifier<CartEntity> {
  @override
  Future<CartEntity> build() => ref.read(cartRepositoryProvider).getCart();

  Future<void> refresh() => _mutate(() => ref.read(cartRepositoryProvider).getCart());

  Future<void> addItem({required String inventoryId, int quantity = 1}) async {
    if (inventoryId.isEmpty || quantity < 1) {
      throw ArgumentError('A valid inventory ID and positive quantity are required.');
    }
    // The server enforces store consistency. Never silently clear a different store's cart.
    await _mutate(() => ref.read(cartRepositoryProvider).addItem(
      inventoryId: inventoryId,
      quantity: quantity,
    ));
  }

  Future<void> updateQuantity({required String cartItemId, required int quantity}) {
    return _mutate(() => quantity <= 0
        ? ref.read(cartRepositoryProvider).removeItem(cartItemId: cartItemId)
        : ref.read(cartRepositoryProvider).updateQuantity(
            cartItemId: cartItemId, quantity: quantity));
  }

  Future<void> removeItem(String cartItemId) =>
      _mutate(() => ref.read(cartRepositoryProvider).removeItem(cartItemId: cartItemId));

  Future<void> clear() =>
      _mutate(() => ref.read(cartRepositoryProvider).clearCart());

  Future<void> _mutate(Future<CartEntity> Function() operation) async {
    // Preserve the previous cart on transient failures.
    final previous = state;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(operation);
    state = result.hasError && previous.hasValue ? previous : result;
    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }
  }
}
