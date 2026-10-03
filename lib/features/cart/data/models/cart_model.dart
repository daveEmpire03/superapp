import '../../domain/entities/cart_entity.dart';
import 'cart_item_model.dart';

class CartModel extends CartEntity {
  const CartModel({
    required super.id,
    required super.storeId,
    required super.storeName,
    required super.items,
    required super.itemCount,
    required super.subtotal,
    super.createdAt,
    super.updatedAt,
  });

  factory CartModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawItems = json['items'];

    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map(
              (item) => CartItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <CartItemModel>[];

    return CartModel(
      id: _requiredString(
        json['id'],
        field: 'id',
      ),
      storeId: _nullableString(
        json['store'] ?? json['store_id'],
      ),
      storeName: _nullableString(
        json['store_name'],
      ),
      items: items,
      itemCount: _toInt(
        json['item_count'],
        fallback: items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        ),
      ),
      subtotal: _toDouble(
        json['subtotal'],
      ),
      createdAt: _toDateTime(
        json['created_at'],
      ),
      updatedAt: _toDateTime(
        json['updated_at'],
      ),
    );
  }

  static String _requiredString(
    dynamic value, {
    required String field,
  }) {
    if (value == null) {
      throw FormatException(
        'Cart response is missing required field "$field".',
      );
    }

    final parsed = value.toString().trim();

    if (parsed.isEmpty) {
      throw FormatException(
        'Cart field "$field" cannot be empty.',
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

  static int _toInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }
}
