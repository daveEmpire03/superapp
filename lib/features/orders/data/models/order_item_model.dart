import '../../domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.sku,
    required super.unitPrice,
    required super.quantity,
    required super.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] ?? '').toString(),
      productId: (json['product'] ?? json['product_id'] ?? '').toString(),
      productName: (json['product_name'] ?? json['name'] ?? 'Item').toString(),
      sku: (json['sku'] ?? '').toString(),
      unitPrice: _toDouble(json['unit_price']),
      quantity: _toInt(json['quantity']),
      lineTotal: _toDouble(json['line_total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': productId,
      'product_name': productName,
      'sku': sku,
      'unit_price': unitPrice,
      'quantity': quantity,
      'line_total': lineTotal,
    };
  }

  static double _toDouble(dynamic val) {
    if (val is num) return val.toDouble();
    return double.tryParse(val?.toString() ?? '') ?? 0.0;
  }

  static int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val?.toString() ?? '') ?? 1;
  }
}
