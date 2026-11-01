import 'package:equatable/equatable.dart';

import 'order_item_entity.dart';
import 'order_status_history_entity.dart';

enum BackendOrderStatus {
  pending('PENDING', 'Pending'),
  confirmed('CONFIRMED', 'Confirmed'),
  preparing('PREPARING', 'Preparing'),
  ready('READY', 'Ready for Pickup'),
  dispatched('DISPATCHED', 'Dispatched'),
  outForDelivery('OUT_FOR_DELIVERY', 'Out for Delivery'),
  delivered('DELIVERED', 'Delivered'),
  cancelled('CANCELLED', 'Cancelled'),
  expired('EXPIRED', 'Expired');

  final String value;
  final String label;

  const BackendOrderStatus(this.value, this.label);

  static BackendOrderStatus fromString(String? val) {
    if (val == null) return BackendOrderStatus.pending;
    final normalized = val.trim().toUpperCase();
    for (final s in BackendOrderStatus.values) {
      if (s.value == normalized) return s;
    }
    return BackendOrderStatus.pending;
  }
}

enum OrderPaymentStatus {
  unpaid('UNPAID', 'Unpaid'),
  pending('PENDING', 'Payment Pending'),
  paid('PAID', 'Paid'),
  failed('FAILED', 'Payment Failed'),
  refunded('REFUNDED', 'Refunded');

  final String value;
  final String label;

  const OrderPaymentStatus(this.value, this.label);

  static OrderPaymentStatus fromString(String? val) {
    if (val == null) return OrderPaymentStatus.unpaid;
    final normalized = val.trim().toUpperCase();
    for (final p in OrderPaymentStatus.values) {
      if (p.value == normalized) return p;
    }
    return OrderPaymentStatus.unpaid;
  }
}

enum OrderFulfilmentType {
  delivery('DELIVERY', 'Home Delivery'),
  pickup('PICKUP', 'Store Pickup');

  final String value;
  final String label;

  const OrderFulfilmentType(this.value, this.label);

  static OrderFulfilmentType fromString(String? val) {
    if (val == null) return OrderFulfilmentType.delivery;
    final normalized = val.trim().toUpperCase();
    for (final f in OrderFulfilmentType.values) {
      if (f.value == normalized) return f;
    }
    return OrderFulfilmentType.delivery;
  }
}

class OrderEntity extends Equatable {
  final String id;
  final String reference;
  final String storeId;
  final String storeName;
  final OrderFulfilmentType fulfilmentType;
  final BackendOrderStatus status;
  final OrderPaymentStatus paymentStatus;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final String promotionCode;
  final Map<String, dynamic> deliveryAddressSnapshot;
  final String notes;
  final DateTime? reservationExpiresAt;
  final List<OrderItemEntity> items;
  final List<OrderStatusHistoryEntity> statusHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderEntity({
    required this.id,
    required this.reference,
    required this.storeId,
    required this.storeName,
    required this.fulfilmentType,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    this.discount = 0.0,
    this.deliveryFee = 0.0,
    required this.total,
    this.promotionCode = '',
    this.deliveryAddressSnapshot = const {},
    this.notes = '',
    this.reservationExpiresAt,
    this.items = const [],
    this.statusHistory = const [],
    this.createdAt,
    this.updatedAt,
  });

  bool get isDelivered => status == BackendOrderStatus.delivered;

  bool get isCancelled =>
      status == BackendOrderStatus.cancelled ||
      status == BackendOrderStatus.expired;

  bool get isActive => !isDelivered && !isCancelled;

  bool get isPaid => paymentStatus == OrderPaymentStatus.paid;

  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  String get formattedAddress {
    final street = deliveryAddressSnapshot['street_address'] ??
        deliveryAddressSnapshot['streetAddress'] ??
        deliveryAddressSnapshot['address'] ??
        '';
    final city = deliveryAddressSnapshot['city'] ?? '';
    final state = deliveryAddressSnapshot['state'] ?? '';
    final parts = [street, city, state]
        .where((p) => p.toString().trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Delivery Address' : parts.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        reference,
        storeId,
        storeName,
        fulfilmentType,
        status,
        paymentStatus,
        subtotal,
        discount,
        deliveryFee,
        total,
        promotionCode,
        deliveryAddressSnapshot,
        notes,
        reservationExpiresAt,
        items,
        statusHistory,
        createdAt,
        updatedAt,
      ];
}
