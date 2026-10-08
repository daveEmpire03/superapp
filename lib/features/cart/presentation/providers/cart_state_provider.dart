import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../../domain/entities/cart_entity.dart';

typedef Emitter<T> = void Function(T value);

final cartStateProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

class CartController extends Notifier<CartState> {
  CartRepository get cartRepository => ref.read(cartRepositoryProvider);

  @override
  CartState build() => const CartInitial();

  void _emit(CartState value) { state = value; }

  Future<void> add(CartEvent event) async {
    if (event is LoadCartEvent) {
      await _onLoadCart(event, _emit);
    }     else if (event is AddToCartEvent) {
      await _onAddToCart(event, _emit);
    }     else if (event is ConfirmStoreChangeEvent) {
      await _onConfirmStoreChange(event, _emit);
    }     else if (event is CancelStoreChangeEvent) {
      await _onCancelStoreChange(event, _emit);
    }     else if (event is UpdateCartQuantityEvent) {
      await _onUpdateCartQuantity(event, _emit);
    }     else if (event is RemoveFromCartEvent) {
      await _onRemoveFromCart(event, _emit);
    }     else if (event is ClearCartEvent) {
      await _onClearCart(event, _emit);
    }
  }

  Future<void> _onLoadCart(
    LoadCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());

    try {
      final cart = await cartRepository.getCart();

      emit(
        CartLoaded(
          cart: cart,
        ),
      );
    } catch (error) {
      emit(
        CartError(
          _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    if (event.inventoryId.trim().isEmpty) {
      return;
    }

    if (event.quantity <= 0) {
      return;
    }

    try {
      final currentCart = await _getCurrentCart();

      if (_hasStoreConflict(
        currentCart,
        event.storeId,
      )) {
        emit(
          CartStoreConflict(
            currentCart: currentCart,
            pendingInventoryId: event.inventoryId,
            pendingProductName: event.productName,
            pendingQuantity: event.quantity,
            currentStoreId: currentCart.storeId,
            newStoreId: event.storeId,
          ),
        );

        return;
      }

      final updatedCart = await cartRepository.addItem(
        inventoryId: event.inventoryId,
        quantity: event.quantity,
      );

      emit(
        CartLoaded(
          cart: updatedCart,
        ),
      );
    } catch (error) {
      emit(
        CartError(
          _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onConfirmStoreChange(
    ConfirmStoreChangeEvent event,
    Emitter<CartState> emit,
  ) async {
    if (event.inventoryId.trim().isEmpty) {
      return;
    }

    if (event.quantity <= 0) {
      return;
    }

    try {
      // Only this explicit confirmation path is allowed
      // to destroy the existing cart from another store.
      await cartRepository.clearCart();

      final updatedCart = await cartRepository.addItem(
        inventoryId: event.inventoryId,
        quantity: event.quantity,
      );

      emit(
        CartLoaded(
          cart: updatedCart,
        ),
      );
    } catch (error) {
      emit(
        CartError(
          _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onCancelStoreChange(
    CancelStoreChangeEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cart = await cartRepository.getCart();

      emit(
        CartLoaded(
          cart: cart,
        ),
      );
    } catch (error) {
      emit(
        CartError(
          _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onUpdateCartQuantity(
    UpdateCartQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    if (event.cartItemId.trim().isEmpty) {
      return;
    }

    try {
      late final CartEntity updatedCart;

      if (event.quantity <= 0) {
        updatedCart = await cartRepository.removeItem(
          cartItemId: event.cartItemId,
        );
      } else {
        updatedCart = await cartRepository.updateQuantity(
          cartItemId: event.cartItemId,
          quantity: event.quantity,
        );
      }

      emit(
        CartLoaded(
          cart: updatedCart,
        ),
      );
    } catch (error) {
      emit(
        CartError(
          _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    if (event.cartItemId.trim().isEmpty) {
      return;
    }

    try {
      final updatedCart = await cartRepository.removeItem(
        cartItemId: event.cartItemId,
      );

      emit(
        CartLoaded(
          cart: updatedCart,
        ),
      );
    } catch (error) {
      emit(
        CartError(
          _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final updatedCart = await cartRepository.clearCart();

      emit(
        CartLoaded(
          cart: updatedCart,
        ),
      );
    } catch (error) {
      emit(
        CartError(
          _errorMessage(error),
        ),
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
