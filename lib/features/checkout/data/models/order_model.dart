import 'package:bokku_mart/features/cart/data/models/cart_item_model.dart';

import '../../domain/entities/order_entity.dart';
import 'address_model.dart';
import 'store_location_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.date,
    required super.status,
    required super.items,
    required super.subtotal,
    required super.discount,
    required super.deliveryFee,
    required super.total,
    required super.deliveryMethod,
    super.deliveryAddress,
    super.pickupStore,
    required super.paymentMethod,
    required super.estimatedArrival,
    super.rider,
  });

  static OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready_dispatch':
        return OrderStatus.readyDispatch;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.confirmed;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    RiderInfo? riderInfo;
    if (json['rider'] is Map) {
      final r = json['rider'] as Map;
      riderInfo = RiderInfo(
        name: r['name'] as String? ?? 'Rider',
        phone: r['phone'] as String? ?? '',
        vehicle: r['vehicle'] as String? ?? '',
        rating: (r['rating'] as num?)?.toDouble() ?? 4.9,
      );
    }

    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      date: json['date'] as String? ?? 'Today',
      status: _parseStatus(json['status'] as String?),
      items: (json['items'] as List?)
              ?.map((i) => CartItemModel.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      deliveryMethod: json['deliveryMethod'] as String? ?? 'delivery',
      deliveryAddress: json['deliveryAddress'] != null
          ? AddressModel.fromJson(
              json['deliveryAddress'] as Map<String, dynamic>)
          : null,
      pickupStore: json['pickupStore'] != null
          ? StoreLocationModel.fromJson(
              json['pickupStore'] as Map<String, dynamic>)
          : null,
      paymentMethod: json['paymentMethod'] as String? ?? 'Debit Card',
      estimatedArrival: json['estimatedArrival'] as String? ?? 'Within 45 mins',
      rider: riderInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'date': date,
      'status': status.name,
      'subtotal': subtotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'total': total,
      'deliveryMethod': deliveryMethod,
      'paymentMethod': paymentMethod,
      'estimatedArrival': estimatedArrival,
    };
  }
}
