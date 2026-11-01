import '../entities/order_entity.dart';

abstract class OrderRepository {
  /// Fetches order history for current authenticated user.
  Future<List<OrderEntity>> getOrders();

  /// Fetches detailed order information by UUID.
  Future<OrderEntity> getOrderDetail(String orderId);

  /// Performs checkout from the user's current server cart.
  Future<OrderEntity> checkout({
    required OrderFulfilmentType fulfilmentType,
    Map<String, dynamic>? deliveryAddress,
    String? notes,
    String? promotionCode,
  });
}
