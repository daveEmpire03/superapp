import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final CartEntity cart;

  const CartLoaded({
    required this.cart,
  });

  /// Convenience getters for the UI.
  List<CartItemEntity> get items => cart.items;

  int get totalItemCount => cart.itemCount;

  double get subtotal => cart.subtotal;

  bool get isEmpty => cart.isEmpty;

  bool get isNotEmpty => cart.isNotEmpty;

  String? get storeId => cart.storeId;

  String? get storeName => cart.storeName;

  @override
  List<Object?> get props => [
        cart,
      ];
}

class CartStoreConflict extends CartState {
  /// Existing cart already associated with another store.
  final CartEntity currentCart;

  /// Inventory item the user attempted to add.
  final String pendingInventoryId;

  /// Optional name used only for displaying a useful message
  /// to the user.
  final String? pendingProductName;

  final int pendingQuantity;

  final String? currentStoreId;
  final String? newStoreId;

  const CartStoreConflict({
    required this.currentCart,
    required this.pendingInventoryId,
    this.pendingProductName,
    required this.pendingQuantity,
    required this.currentStoreId,
    required this.newStoreId,
  });

  /// Convenience getter for existing UI code.
  List<CartItemEntity> get currentItems {
    return currentCart.items;
  }

  @override
  List<Object?> get props => [
        currentCart,
        pendingInventoryId,
        pendingProductName,
        pendingQuantity,
        currentStoreId,
        newStoreId,
      ];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [
        message,
      ];
}
