import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  /// Unique cart-item ID returned by Django.
  ///
  /// This ID is used when updating or removing
  /// an existing item from the cart.
  final String id;

  /// StoreInventory ID.
  ///
  /// This identifies the exact product inventory
  /// record belonging to a specific store.
  final String inventoryId;

  /// Catalog product ID.
  final String productId;

  /// Product information required by the cart UI.
  final String productName;
  final String? productImageUrl;
  final String sku;

  /// Quantity currently in the cart.
  final int quantity;

  /// Current store-specific price returned by Django.
  final double unitPrice;

  /// Current available stock returned by Django.
  final int availableQuantity;

  /// Authoritative line total returned by Django.
  final double lineTotal;

  const CartItemEntity({
    required this.id,
    required this.inventoryId,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.availableQuantity,
    required this.lineTotal,
  });

  bool get canIncrement {
    return quantity < availableQuantity;
  }

  bool get isOutOfStock {
    return availableQuantity <= 0;
  }

  CartItemEntity copyWith({
    String? id,
    String? inventoryId,
    String? productId,
    String? productName,
    String? productImageUrl,
    String? sku,
    int? quantity,
    double? unitPrice,
    int? availableQuantity,
    double? lineTotal,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      inventoryId: inventoryId ?? this.inventoryId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      lineTotal: lineTotal ?? this.lineTotal,
    );
  }

  @override
  List<Object?> get props => [
        id,
        inventoryId,
        productId,
        productName,
        productImageUrl,
        sku,
        quantity,
        unitPrice,
        availableQuantity,
        lineTotal,
      ];
}
