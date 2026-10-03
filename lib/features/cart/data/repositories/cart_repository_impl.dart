import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<CartEntity> getCart() {
    return remoteDataSource.getCart();
  }

  @override
  Future<CartEntity> addItem({
    required String inventoryId,
    int quantity = 1,
  }) {
    return remoteDataSource.addItem(
      inventoryId: inventoryId,
      quantity: quantity,
    );
  }

  @override
  Future<CartEntity> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) {
    return remoteDataSource.updateQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }

  @override
  Future<CartEntity> removeItem({
    required String cartItemId,
  }) {
    return remoteDataSource.removeItem(
      cartItemId: cartItemId,
    );
  }

  @override
  Future<CartEntity> clearCart() {
    return remoteDataSource.clearCart();
  }
}
