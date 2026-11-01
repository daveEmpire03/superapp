import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders();

  Future<OrderModel> getOrderDetail(String orderId);

  Future<OrderModel> checkout({
    required OrderFulfilmentType fulfilmentType,
    Map<String, dynamic>? deliveryAddress,
    String? notes,
    String? promotionCode,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient dioClient;

  OrderRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await dioClient.get<dynamic>(
      ApiEndpoints.orders,
    );

    return _parseOrderList(response.data);
  }

  @override
  Future<OrderModel> getOrderDetail(String orderId) async {
    final normalizedId = orderId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('orderId cannot be empty.');
    }

    final response = await dioClient.get<dynamic>(
      ApiEndpoints.orderDetail(normalizedId),
    );

    return _parseOrderResponse(response.data);
  }

  @override
  Future<OrderModel> checkout({
    required OrderFulfilmentType fulfilmentType,
    Map<String, dynamic>? deliveryAddress,
    String? notes,
    String? promotionCode,
  }) async {
    final payload = <String, dynamic>{
      'fulfilment_type': fulfilmentType.value,
      if (deliveryAddress != null && deliveryAddress.isNotEmpty)
        'delivery_address': deliveryAddress,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      if (promotionCode != null && promotionCode.trim().isNotEmpty)
        'promotion_code': promotionCode.trim().toUpperCase(),
    };

    final response = await dioClient.post<dynamic>(
      ApiEndpoints.checkout,
      data: payload,
    );

    return _parseOrderResponse(response.data);
  }

  OrderModel _parseOrderResponse(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final nested = map['data'] ?? map['order'];
      if (nested is Map) {
        return OrderModel.fromJson(Map<String, dynamic>.from(nested));
      }
      return OrderModel.fromJson(map);
    }

    throw const FormatException('Expected order data in server response.');
  }

  List<OrderModel> _parseOrderList(dynamic data) {
    final list = _extractList(data);
    return list
        .whereType<Map>()
        .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final results = map['results'] ?? map['data'];
      if (results is List) return results;
    }

    return const [];
  }
}
