import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String? subCategory;
  final String size;

  /// StoreInventory ID for the currently selected store.
  ///
  /// This is intentionally different from [id].
  /// [id] identifies the catalog product, while [inventoryId]
  /// identifies that product's inventory record at a specific store.
  ///
  /// Nullable temporarily so existing mock/local products continue
  /// working while the app migrates fully to backend inventory data.
  final String? inventoryId;

  /// Price for this product at the currently selected store.
  final double price;

  /// Previous/original price when the product is discounted.
  final double? oldPrice;

  final String imageUrl;

  /// Store-specific availability.
  final bool inStock;

  /// Store-specific quantity currently available.
  final int stockCount;

  /// Store whose inventory/pricing produced this product response.
  ///
  /// Nullable temporarily so existing mock/local products do not break
  /// while we migrate to the backend store inventory API.
  final int? storeId;

  final double rating;
  final int reviewsCount;
  final String? badge;
  final String description;
  final Map<String, String> details;
  final String deliveryInfo;
  final bool isDeal;
  final String? dealType;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    this.subCategory,
    required this.size,
    this.inventoryId,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    this.inStock = true,
    this.stockCount = 50,
    this.storeId,
    this.rating = 4.8,
    this.reviewsCount = 20,
    this.badge,
    required this.description,
    this.details = const {},
    required this.deliveryInfo,
    this.isDeal = false,
    this.dealType,
  });

  bool get hasDiscount {
    return oldPrice != null && oldPrice! > price;
  }

  double get discountAmount {
    return hasDiscount ? oldPrice! - price : 0;
  }

  int get discountPercentage {
    if (!hasDiscount) {
      return 0;
    }

    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }

  /// Product can only be purchased when the backend says it is
  /// in stock and its available quantity is greater than zero.
  bool get isAvailable {
    return inStock && stockCount > 0;
  }

  /// The product can be sent to the cart only when we know the exact
  /// StoreInventory record that should be purchased.
  bool get hasInventory {
    return inventoryId != null && inventoryId!.trim().isNotEmpty;
  }

  /// Useful for showing a low-stock warning in the UI.
  bool get isLowStock {
    return isAvailable && stockCount <= 5;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        category,
        subCategory,
        size,
        inventoryId,
        price,
        oldPrice,
        imageUrl,
        inStock,
        stockCount,
        storeId,
        rating,
        reviewsCount,
        badge,
        description,
        details,
        deliveryInfo,
        isDeal,
        dealType,
      ];
}
