import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}

class AddToCartEvent extends CartEvent {
  final String inventoryId;
  final String? storeId;
  final String? productName;
  final int quantity;

  const AddToCartEvent({
    required this.inventoryId,
    required this.storeId,
    this.productName,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [
        inventoryId,
        storeId,
        productName,
        quantity,
      ];
}

class ConfirmStoreChangeEvent extends CartEvent {
  final String inventoryId;
  final String? storeId;
  final String? productName;
  final int quantity;

  const ConfirmStoreChangeEvent({
    required this.inventoryId,
    required this.storeId,
    this.productName,
    required this.quantity,
  });

  @override
  List<Object?> get props => [
        inventoryId,
        storeId,
        productName,
        quantity,
      ];
}

class CancelStoreChangeEvent extends CartEvent {
  const CancelStoreChangeEvent();
}

class UpdateCartQuantityEvent extends CartEvent {
  final String cartItemId;
  final int quantity;

  const UpdateCartQuantityEvent(
    this.cartItemId,
    this.quantity,
  );

  @override
  List<Object?> get props => [
        cartItemId,
        quantity,
      ];
}

class RemoveFromCartEvent extends CartEvent {
  final String cartItemId;

  const RemoveFromCartEvent(
    this.cartItemId,
  );

  @override
  List<Object?> get props => [
        cartItemId,
      ];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}
