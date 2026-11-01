import 'package:equatable/equatable.dart';

class OrderStatusHistoryEntity extends Equatable {
  final String id;
  final String status;
  final String note;
  final DateTime? createdAt;

  const OrderStatusHistoryEntity({
    required this.id,
    required this.status,
    this.note = '',
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, status, note, createdAt];
}
