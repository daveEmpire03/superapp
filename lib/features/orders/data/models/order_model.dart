import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';
import 'order_status_history_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.reference,
    required super.storeId,
    required super.storeName,
    required super.fulfilmentType,
    required super.status,
    required super.paymentStatus,
    required super.subtotal,
    super.discount,
    super.deliveryFee,
    required super.total,
    super.promotionCode,
    super.deliveryAddressSnapshot,
    super.notes,
    super.reservationExpiresAt,
    super.items,
    super.statusHistory,
    super.createdAt,
    super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((i) => OrderItemModel.fromJson(Map<String, dynamic>.from(i)))
            .toList()
        : <OrderItemModel>[];

    final rawHistory = json['status_history'];
    final history = rawHistory is List
        ? rawHistory
            .whereType<Map>()
            .map((h) =>
                OrderStatusHistoryModel.fromJson(Map<String, dynamic>.from(h)))
            .toList()
        : <OrderStatusHistoryModel>[];

    return OrderModel(
      id: (json['id'] ?? '').toString(),
      reference: (json['reference'] ?? json['order_number'] ?? json['id'] ?? '')
          .toString(),
      storeId: (json['store'] ?? json['store_id'] ?? '').toString(),
      storeName: (json['store_name'] ?? 'Bokku Mart Store').toString(),
      fulfilmentType: OrderFulfilmentType.fromString(
        json['fulfilment_type']?.toString(),
      ),
      status: BackendOrderStatus.fromString(
        json['status']?.toString(),
      ),
      paymentStatus: OrderPaymentStatus.fromString(
        json['payment_status']?.toString(),
      ),
      subtotal: _toDouble(json['subtotal']),
      discount: _toDouble(json['discount']),
      deliveryFee: _toDouble(json['delivery_fee'] ?? json['deliveryFee']),
      total: _toDouble(json['total']),
      promotionCode: (json['promotion_code'] ?? '').toString(),
      deliveryAddressSnapshot: _toMap(json['delivery_address_snapshot'] ??
          json['delivery_address'] ??
          json['deliveryAddress']),
      notes: (json['notes'] ?? '').toString(),
      reservationExpiresAt: _toDateTime(json['reservation_expires_at']),
      items: items,
      statusHistory: history,
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'store': storeId,
      'store_name': storeName,
      'fulfilment_type': fulfilmentType.value,
      'status': status.value,
      'payment_status': paymentStatus.value,
      'subtotal': subtotal,
      'discount': discount,
      'delivery_fee': deliveryFee,
      'total': total,
      'promotion_code': promotionCode,
      'delivery_address_snapshot': deliveryAddressSnapshot,
      'notes': notes,
      'reservation_expires_at': reservationExpiresAt?.toIso8601String(),
      'items': items
          .map((i) => i is OrderItemModel
              ? i.toJson()
              : OrderItemModel(
                  id: i.id,
                  productId: i.productId,
                  productName: i.productName,
                  sku: i.sku,
                  unitPrice: i.unitPrice,
                  quantity: i.quantity,
                  lineTotal: i.lineTotal,
                ).toJson())
          .toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static double _toDouble(dynamic val) {
    if (val is num) return val.toDouble();
    return double.tryParse(val?.toString() ?? '') ?? 0.0;
  }

  static Map<String, dynamic> _toMap(dynamic val) {
    if (val is Map) return Map<String, dynamic>.from(val);
    return const {};
  }

  static DateTime? _toDateTime(dynamic val) {
    if (val == null) return null;
    return DateTime.tryParse(val.toString());
  }
}
