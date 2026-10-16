import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/cart_repository.dart';
import '../bloc/cart_state.dart';
import '../../domain/entities/cart_entity.dart';

final cartStateProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

class CartController extends Notifier<CartState> {
  CartRepository get cartRepository => ref.read(cartRepositoryProvider);

  @override
  CartState build() => const CartInitial();

  Future<void> loadCart() async {
    state = const CartLoading();

    try {
      final cart = await cartRepository.getCart();

      state = CartLoaded(
        cart: cart,
      );
    } catch (error) {
      state = CartError(
        _errorMessage(error),
      );
    }
  }

  Future<void> addToCart({
    required String inventoryId,
    required String? storeId,
    String? productName,
    int quantity = 1,
  }) async {
    if (inventoryId.trim().isEmpty) {
      return;
    }

    if (quantity <= 0) {
      return;
    }

    try {
      final currentCart = await _getCurrentCart();

      if (_hasStoreConflict(
        currentCart,
        storeId,
      )) {
        state = CartStoreConflict(
          currentCart: currentCart,
          pendingInventoryId: inventoryId,
          pendingProductName: productName,
          pendingQuantity: quantity,
          currentStoreId: currentCart.storeId,
          newStoreId: storeId,
        );

        return;
      }

      final updatedCart = await cartRepository.addItem(
        inventoryId: inventoryId,
        quantity: quantity,
      );

      state = CartLoaded(
        cart: updatedCart,
      );
    } catch (error) {
      state = CartError(
        _errorMessage(error),
      );
    }
  }

  Future<void> confirmStoreChange({
    required String inventoryId,
    required String? storeId,
    String? productName,
    required int quantity,
  }) async {
    if (inventoryId.trim().isEmpty) {
      return;
    }

    if (quantity <= 0) {
      return;
    }

    try {
      // Only this explicit confirmation path is allowed
      // to destroy the existing cart from another store.
      await cartRepository.clearCart();

      final updatedCart = await cartRepository.addItem(
        inventoryId: inventoryId,
        quantity: quantity,
      );

      state = CartLoaded(
        cart: updatedCart,
      );
    } catch (error) {
      state = CartError(
        _errorMessage(error),
      );
    }
  }

  Future<void> cancelStoreChange() async {
    try {
      final cart = await cartRepository.getCart();

      state = CartLoaded(
        cart: cart,
      );
    } catch (error) {
      state = CartError(
        _errorMessage(error),
      );
    }
  }

  Future<void> updateCartQuantity(
    String cartItemId,
    int quantity,
  ) async {
    if (cartItemId.trim().isEmpty) {
      return;
    }

    try {
      late final CartEntity updatedCart;

      if (quantity <= 0) {
        updatedCart = await cartRepository.removeItem(
          cartItemId: cartItemId,
        );
      } else {
        updatedCart = await cartRepository.updateQuantity(
          cartItemId: cartItemId,
          quantity: quantity,
        );
      }

      state = CartLoaded(
        cart: updatedCart,
      );
    } catch (error) {
      state = CartError(
        _errorMessage(error),
      );
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (cartItemId.trim().isEmpty) {
      return;
    }

    try {
      final updatedCart = await cartRepository.removeItem(
        cartItemId: cartItemId,
      );

      state = CartLoaded(
        cart: updatedCart,
      );
    } catch (error) {
      state = CartError(
        _errorMessage(error),
      );
    }
  }

  Future<void> clearCart() async {
    try {
      final updatedCart = await cartRepository.clearCart();

      state = CartLoaded(
        cart: updatedCart,
      );
    } catch (error) {
      state = CartError(
        _errorMessage(error),
      );
    }
  }



  Future<CartEntity> _getCurrentCart() async {
    final currentState = state;

    if (currentState is CartLoaded) {
      return currentState.cart;
    }

    if (currentState is CartStoreConflict) {
      return currentState.currentCart;
    }

    return cartRepository.getCart();
  }

  bool _hasStoreConflict(
    CartEntity cart,
    String? newStoreId,
  ) {
    if (cart.isEmpty) {
      return false;
    }

    final currentStoreId = cart.storeId;

    if (currentStoreId == null || newStoreId == null) {
      return false;
    }

    return currentStoreId != newStoreId;
  }

  String _errorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    if (message.startsWith('ArgumentError: ')) {
      return message.substring(
        'ArgumentError: '.length,
      );
    }

    return message;
  }
}
