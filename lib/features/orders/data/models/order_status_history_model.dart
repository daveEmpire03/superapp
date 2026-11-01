import '../../domain/entities/order_status_history_entity.dart';

class OrderStatusHistoryModel extends OrderStatusHistoryEntity {
  const OrderStatusHistoryModel({
    required super.id,
    required super.status,
    super.note,
    super.createdAt,
  });

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      id: (json['id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'note': note,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static DateTime? _toDateTime(dynamic val) {
    if (val == null) return null;
    return DateTime.tryParse(val.toString());
  }
}
