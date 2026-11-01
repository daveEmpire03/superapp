import 'package:equatable/equatable.dart';

enum DeliveryStatus {
  pending,
  assigned,
  accepted,
  pickedUp,
  outForDelivery,
  delivered,
  rejected,
  cancelled;

  static DeliveryStatus fromString(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'PENDING':
        return DeliveryStatus.pending;
      case 'ASSIGNED':
        return DeliveryStatus.assigned;
      case 'ACCEPTED':
        return DeliveryStatus.accepted;
      case 'PICKED_UP':
        return DeliveryStatus.pickedUp;
      case 'OUT_FOR_DELIVERY':
        return DeliveryStatus.outForDelivery;
      case 'DELIVERED':
        return DeliveryStatus.delivered;
      case 'REJECTED':
        return DeliveryStatus.rejected;
      case 'CANCELLED':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.pending;
    }
  }

  String get wire => name == 'pickedUp'
      ? 'PICKED_UP'
      : name == 'outForDelivery'
      ? 'OUT_FOR_DELIVERY'
      : name.toUpperCase();

  String get label {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.assigned:
        return 'Assigned';
      case DeliveryStatus.accepted:
        return 'Accepted';
      case DeliveryStatus.pickedUp:
        return 'Picked Up';
      case DeliveryStatus.outForDelivery:
        return 'Out for Delivery';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.rejected:
        return 'Rejected';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isTerminal =>
      this == DeliveryStatus.delivered ||
      this == DeliveryStatus.rejected ||
      this == DeliveryStatus.cancelled;

  bool get isActive => !isTerminal;
}

// -----------------------------------------------------------------------------
// Snapshot entities — frozen at order time
// -----------------------------------------------------------------------------

class DeliveryAddress extends Equatable {
  final String recipientName;
  final String phone;
  final String addressLine;
  final String city;
  final String state;
  final String landmark;
  final double? latitude;
  final double? longitude;

  const DeliveryAddress({
    required this.recipientName,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.landmark,
    required this.latitude,
    required this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get isEmpty =>
      addressLine.isEmpty &&
      city.isEmpty &&
      state.isEmpty &&
      landmark.isEmpty &&
      !hasCoordinates;

  String get oneLine {
    final parts = [
      addressLine,
      city,
      state,
      if (landmark.isNotEmpty) 'near $landmark',
    ].where((p) => p.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const DeliveryAddress(
        recipientName: '',
        phone: '',
        addressLine: '',
        city: '',
        state: '',
        landmark: '',
        latitude: null,
        longitude: null,
      );
    }

    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return DeliveryAddress(
      recipientName: json['recipient_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      addressLine: json['address_line']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      latitude: asDouble(json['latitude']),
      longitude: asDouble(json['longitude']),
    );
  }

  @override
  List<Object?> get props => [
    recipientName,
    phone,
    addressLine,
    city,
    state,
    landmark,
    latitude,
    longitude,
  ];
}

class RiderOrderItem extends Equatable {
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const RiderOrderItem({
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  @override
  List<Object?> get props => [productName, sku, quantity, unitPrice, lineTotal];
}

// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------

class DeliveryHistoryEntry extends Equatable {
  final String id;
  final DeliveryStatus status;
  final String? changedById;
  final String? changedByName;
  final String note;
  final DateTime createdAt;

  const DeliveryHistoryEntry({
    required this.id,
    required this.status,
    required this.changedById,
    required this.changedByName,
    required this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    status,
    changedById,
    changedByName,
    note,
    createdAt,
  ];
}

// -----------------------------------------------------------------------------
// Core entity
// -----------------------------------------------------------------------------

class RiderJobEntity extends Equatable {
  final String id;
  final String orderId;
  final String orderReference;
  final String orderStatus;
  final String storeId;
  final String storeName;

  final String customerName;
  final String customerPhone;
  final DeliveryAddress deliveryAddress;
  final List<RiderOrderItem> items;

  final String? riderId;
  final String? riderName;
  final DeliveryStatus status;

  final DateTime? assignedAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  final String deliveryNote;
  final String proofNote;

  final double payoutAmount;

  final List<DeliveryHistoryEntry> history;

  final DateTime createdAt;
  final DateTime updatedAt;

  const RiderJobEntity({
    required this.id,
    required this.orderId,
    required this.orderReference,
    required this.orderStatus,
    required this.storeId,
    required this.storeName,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.riderId,
    required this.riderName,
    required this.status,
    required this.assignedAt,
    required this.acceptedAt,
    required this.pickedUpAt,
    required this.outForDeliveryAt,
    required this.deliveredAt,
    required this.cancelledAt,
    required this.deliveryNote,
    required this.proofNote,
    required this.payoutAmount,
    required this.history,
    required this.createdAt,
    required this.updatedAt,
  });

  DeliveryStatus? get nextAction {
    switch (status) {
      case DeliveryStatus.assigned:
        return DeliveryStatus.accepted;
      case DeliveryStatus.accepted:
        return DeliveryStatus.pickedUp;
      case DeliveryStatus.pickedUp:
        return DeliveryStatus.outForDelivery;
      case DeliveryStatus.outForDelivery:
        return DeliveryStatus.delivered;
      case DeliveryStatus.pending:
      case DeliveryStatus.delivered:
      case DeliveryStatus.rejected:
      case DeliveryStatus.cancelled:
        return null;
    }
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    orderReference,
    orderStatus,
    storeId,
    storeName,
    customerName,
    customerPhone,
    deliveryAddress,
    items,
    riderId,
    riderName,
    status,
    assignedAt,
    acceptedAt,
    pickedUpAt,
    outForDeliveryAt,
    deliveredAt,
    cancelledAt,
    deliveryNote,
    proofNote,
    payoutAmount,
    history,
    createdAt,
    updatedAt,
  ];
}
