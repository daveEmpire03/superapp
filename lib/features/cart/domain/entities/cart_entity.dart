import 'package:equatable/equatable.dart';

import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  /// Unique Django cart ID.
  final String id;

  /// Store associated with the cart.
  ///
  /// This can be null when the cart is empty.
  final String? storeId;

  /// Human-readable store name returned by Django.
  final String? storeName;

  /// Items currently in the cart.
  final List<CartItemEntity> items;

  /// Total number of product units in the cart.
  ///
  /// Example:
  /// 2 Coke + 3 Rice = 5.
  final int itemCount;

  /// Authoritative subtotal returned by Django.
  final double subtotal;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartEntity({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.items,
    required this.itemCount,
    required this.subtotal,
    this.createdAt,
    this.updatedAt,
  });

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  CartItemEntity? findItemByProductId(
    String productId,
  ) {
    for (final item in items) {
      if (item.productId == productId) {
        return item;
      }
    }

    return null;
  }

  CartItemEntity? findItemByInventoryId(
    String inventoryId,
  ) {
    for (final item in items) {
      if (item.inventoryId == inventoryId) {
        return item;
      }
    }

    return null;
  }

  CartEntity copyWith({
    String? id,
    String? storeId,
    String? storeName,
    List<CartItemEntity>? items,
    int? itemCount,
    double? subtotal,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearStore = false,
  }) {
    return CartEntity(
      id: id ?? this.id,
      storeId: clearStore ? null : storeId ?? this.storeId,
      storeName: clearStore ? null : storeName ?? this.storeName,
      items: items ?? this.items,
      itemCount: itemCount ?? this.itemCount,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        storeId,
        storeName,
        items,
        itemCount,
        subtotal,
        createdAt,
        updatedAt,
      ];
}
