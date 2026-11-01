import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        sku,
        unitPrice,
        quantity,
        lineTotal,
      ];
}
