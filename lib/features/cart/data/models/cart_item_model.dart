import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.inventoryId,
    required super.productId,
    required super.productName,
    required super.productImageUrl,
    required super.sku,
    required super.quantity,
    required super.unitPrice,
    required super.availableQuantity,
    required super.lineTotal,
  });

  factory CartItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CartItemModel(
      id: _requiredString(
        json['id'],
        field: 'id',
      ),

      // Supports either:
      // "inventory": 12
      // or
      // "inventory_id": 12
      inventoryId: _requiredString(
        json['inventory'] ?? json['inventory_id'],
        field: 'inventory',
      ),

      // Supports either:
      // "product_id": 8
      // or
      // "product": 8
      productId: _requiredString(
        json['product_id'] ?? json['product'],
        field: 'product_id',
      ),

      productName: _requiredString(
        json['product_name'],
        field: 'product_name',
      ),

      productImageUrl: _nullableString(
        json['product_image'],
      ),

      // Allows compatibility if the backend exposes
      // product_sku instead of sku.
      sku: _requiredString(
        json['sku'] ?? json['product_sku'],
        field: 'sku',
      ),

      quantity: _requiredInt(
        json['quantity'],
        field: 'quantity',
      ),

      unitPrice: _requiredDouble(
        json['unit_price'],
        field: 'unit_price',
      ),

      availableQuantity: _requiredInt(
        json['available_quantity'],
        field: 'available_quantity',
      ),

      lineTotal: _requiredDouble(
        json['line_total'],
        field: 'line_total',
      ),
    );
  }

  factory CartItemModel.fromEntity(
    CartItemEntity entity,
  ) {
    return CartItemModel(
      id: entity.id,
      inventoryId: entity.inventoryId,
      productId: entity.productId,
      productName: entity.productName,
      productImageUrl: entity.productImageUrl,
      sku: entity.sku,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      availableQuantity: entity.availableQuantity,
      lineTotal: entity.lineTotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventory': inventoryId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImageUrl,
      'sku': sku,
      'quantity': quantity,
      'unit_price': unitPrice,
      'available_quantity': availableQuantity,
      'line_total': lineTotal,
    };
  }

  static String _requiredString(
    dynamic value, {
    required String field,
  }) {
    if (value == null) {
      throw FormatException(
        'Cart item is missing required field "$field".',
      );
    }

    final parsed = value.toString().trim();

    if (parsed.isEmpty) {
      throw FormatException(
        'Cart item field "$field" cannot be empty.',
      );
    }

    return parsed;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final parsed = value.toString().trim();

    if (parsed.isEmpty) {
      return null;
    }

    return parsed;
  }

  static int _requiredInt(
    dynamic value, {
    required String field,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    final parsed = int.tryParse(
      value?.toString() ?? '',
    );

    if (parsed == null) {
      throw FormatException(
        'Invalid integer value for cart item field "$field".',
      );
    }

    return parsed;
  }

  static double _requiredDouble(
    dynamic value, {
    required String field,
  }) {
    if (value is num) {
      return value.toDouble();
    }

    final parsed = double.tryParse(
      value?.toString() ?? '',
    );

    if (parsed == null) {
      throw FormatException(
        'Invalid decimal value for cart item field "$field".',
      );
    }

    return parsed;
  }
}
