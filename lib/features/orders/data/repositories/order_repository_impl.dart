import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<OrderEntity>> getOrders() {
    return remoteDataSource.getOrders();
  }

  @override
  Future<OrderEntity> getOrderDetail(String orderId) {
    return remoteDataSource.getOrderDetail(orderId);
  }

  @override
  Future<OrderEntity> checkout({
    required OrderFulfilmentType fulfilmentType,
    Map<String, dynamic>? deliveryAddress,
    String? notes,
    String? promotionCode,
  }) {
    return remoteDataSource.checkout(
      fulfilmentType: fulfilmentType,
      deliveryAddress: deliveryAddress,
      notes: notes,
      promotionCode: promotionCode,
    );
  }
}
