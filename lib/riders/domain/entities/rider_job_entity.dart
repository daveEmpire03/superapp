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

  /// Backend enum value (uppercase).
  String get wire => name == 'pickedUp'
      ? 'PICKED_UP'
      : name == 'outForDelivery'
      ? 'OUT_FOR_DELIVERY'
      : name.toUpperCase();

  /// Human-friendly label for UI.
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

class RiderJobEntity extends Equatable {
  final String id;
  final String orderId;
  final String orderReference;
  final String orderStatus;
  final String storeId;
  final String storeName;
  final String customerName;
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
    required this.history,
    required this.createdAt,
    required this.updatedAt,
  });

  /// What the rider can do next, based on the current status.
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
    history,
    createdAt,
    updatedAt,
  ];
}
