import '../../domain/entities/rider_job_entity.dart';

class RiderJobModel extends RiderJobEntity {
  const RiderJobModel({
    required super.id,
    required super.orderId,
    required super.orderReference,
    required super.orderStatus,
    required super.storeId,
    required super.storeName,
    required super.customerName,
    required super.riderId,
    required super.riderName,
    required super.status,
    required super.assignedAt,
    required super.acceptedAt,
    required super.pickedUpAt,
    required super.outForDeliveryAt,
    required super.deliveredAt,
    required super.cancelledAt,
    required super.deliveryNote,
    required super.proofNote,
    required super.history,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RiderJobModel.fromJson(Map<String, dynamic> json) {
    return RiderJobModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order']?.toString() ?? '',
      orderReference: json['order_reference']?.toString() ?? '',
      orderStatus: json['order_status']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      riderId: json['rider']?.toString(),
      riderName: json['rider_name']?.toString(),
      status: DeliveryStatus.fromString(json['status']?.toString()),
      assignedAt: _parseDate(json['assigned_at']),
      acceptedAt: _parseDate(json['accepted_at']),
      pickedUpAt: _parseDate(json['picked_up_at']),
      outForDeliveryAt: _parseDate(json['out_for_delivery_at']),
      deliveredAt: _parseDate(json['delivered_at']),
      cancelledAt: _parseDate(json['cancelled_at']),
      deliveryNote: json['delivery_note']?.toString() ?? '',
      proofNote: json['proof_note']?.toString() ?? '',
      history: _parseHistory(json['history']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  static List<DeliveryHistoryEntry> _parseHistory(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((e) => _historyEntry(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  static DeliveryHistoryEntry _historyEntry(Map<String, dynamic> json) {
    return DeliveryHistoryEntry(
      id: json['id']?.toString() ?? '',
      status: DeliveryStatus.fromString(json['status']?.toString()),
      changedById: json['changed_by']?.toString(),
      changedByName: json['changed_by_name']?.toString(),
      note: json['note']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
