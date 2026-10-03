import 'package:bokku_mart/features/cart/domain/entities/cart_item_entity.dart';

import '../entities/address_entity.dart';
import '../entities/order_entity.dart';
import '../entities/store_location_entity.dart';

abstract class OrderRepository {
  Future<List<AddressEntity>> getAddresses();
  Future<List<StoreLocationEntity>> getStoreLocations();
  Future<List<OrderEntity>> getOrderHistory();
  Future<OrderEntity> getOrderById(String orderId);
  Future<OrderEntity> placeOrder({
    required List<CartItemEntity> items,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
    required String deliveryMethod,
    AddressEntity? deliveryAddress,
    StoreLocationEntity? pickupStore,
    required String paymentMethod,
  });
}
