import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<CartEntity> getCart();

  Future<CartEntity> addItem({
    required String inventoryId,
    int quantity = 1,
  });

  Future<CartEntity> updateQuantity({
    required String cartItemId,
    required int quantity,
  });

  Future<CartEntity> removeItem({
    required String cartItemId,
  });

  Future<CartEntity> clearCart();
}
