import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({
    required this.cartRepository,
  }) : super(const CartInitial()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<ConfirmStoreChangeEvent>(_onConfirmStoreChange);
    on<CancelStoreChangeEvent>(_onCancelStoreChange);
    on<UpdateCartQuantityEvent>(_onUpdateCartQuantity);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
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
