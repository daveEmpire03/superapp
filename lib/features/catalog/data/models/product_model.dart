import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.category,
    super.subCategory,
    required super.size,
    super.inventoryId,
    required super.price,
    super.oldPrice,
    required super.imageUrl,
    super.inStock,
    super.stockCount,
    super.storeId,
    super.rating,
    super.reviewsCount,
    super.badge,
    required super.description,
    super.details,
    required super.deliveryInfo,
    super.isDeal,
    super.dealType,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final parsedDetails = <String, String>{};

    if (json['details'] is Map) {
      (json['details'] as Map).forEach((key, value) {
        parsedDetails[key.toString()] = value.toString();
      });
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'Bokku Brand',
      category: _parseCategory(json['category']),
      subCategory: (json['sub_category'] ?? json['subCategory'])?.toString(),
      size: json['size']?.toString() ?? '',

      /// Support both the preferred flattened API response:
      ///
      /// {
      ///   "inventory_id": 15
      /// }
      ///
      /// and a nested inventory object if the backend later returns:
      ///
      /// {
      ///   "inventory": {
      ///     "id": 15
      ///   }
      /// }
      inventoryId: _parseInventoryId(json),

      price: _toDouble(json['price']),
      oldPrice: _toNullableDouble(
        json['old_price'] ??
            json['oldPrice'] ??
            json['compare_at_price'] ??
            json['compareAtPrice'],
      ),
      imageUrl: (json['image_url'] ??
                  json['imageUrl'] ??
                  json['image'] ??
                  json['product_image'])
              ?.toString() ??
          '',
      inStock: _toBool(
        json['in_stock'] ??
            json['inStock'] ??
            json['is_in_stock'] ??
            json['isInStock'],
        fallback: true,
      ),
      stockCount: _toInt(
        json['stock_count'] ??
            json['stockCount'] ??
            json['available_quantity'] ??
            json['availableQuantity'],
        fallback: 50,
      ),
      storeId: _parseStoreId(json),
      rating: _toDouble(
        json['rating'],
        fallback: 4.8,
      ),
      reviewsCount: _toInt(
        json['reviews_count'] ?? json['reviewsCount'],
        fallback: 24,
      ),
      badge: json['badge']?.toString(),
      description: json['description']?.toString() ?? '',
      details: parsedDetails,
      deliveryInfo:
          (json['delivery_info'] ?? json['deliveryInfo'])?.toString() ??
              'Standard delivery available',
      isDeal: _toBool(
        json['is_deal'] ?? json['isDeal'],
      ),
      dealType: (json['deal_type'] ?? json['dealType'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'sub_category': subCategory,
      'size': size,
      'inventory_id': inventoryId,
      'price': price,
      'old_price': oldPrice,
      'image_url': imageUrl,
      'in_stock': inStock,
      'stock_count': stockCount,
      'store_id': storeId,
      'rating': rating,
      'reviews_count': reviewsCount,
      'badge': badge,
      'description': description,
      'details': details,
      'delivery_info': deliveryInfo,
      'is_deal': isDeal,
      'deal_type': dealType,
    };
  }

  static String _parseCategory(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is Map) {
      return (value['id'] ?? value['slug'] ?? value['name'] ?? '').toString();
    }

    return value.toString();
  }

  static String? _parseInventoryId(Map<String, dynamic> json) {
    final directValue = json['inventory_id'] ?? json['inventoryId'];

    final directId = _toNullableString(directValue);

    if (directId != null) {
      return directId;
    }

    final inventory = json['inventory'];

    if (inventory is Map) {
      return _toNullableString(
        inventory['id'] ??
            inventory['inventory_id'] ??
            inventory['inventoryId'],
      );
    }

    if (inventory != null) {
      return _toNullableString(inventory);
    }

    final storeInventory = json['store_inventory'] ?? json['storeInventory'];

    if (storeInventory is Map) {
      return _toNullableString(
        storeInventory['id'] ??
            storeInventory['inventory_id'] ??
            storeInventory['inventoryId'],
      );
    }

    return null;
  }

  static int? _parseStoreId(Map<String, dynamic> json) {
    final directStoreId = _toNullableInt(
      json['store_id'] ?? json['storeId'],
    );

    if (directStoreId != null) {
      return directStoreId;
    }

    final store = json['store'];

    if (store is Map) {
      return _toNullableInt(store['id']);
    }

    final storeAsId = _toNullableInt(store);

    if (storeAsId != null) {
      return storeAsId;
    }

    final inventory =
        json['inventory'] ?? json['store_inventory'] ?? json['storeInventory'];

    if (inventory is Map) {
      final nestedStore = inventory['store'];

      if (nestedStore is Map) {
        return _toNullableInt(nestedStore['id']);
      }

      return _toNullableInt(
        inventory['store_id'] ?? inventory['storeId'] ?? nestedStore,
      );
    }

    return null;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final parsed = value.toString().trim();

    if (parsed.isEmpty || parsed == 'null' || parsed == '0') {
      return null;
    }

    return parsed;
  }

  static double _toDouble(
    dynamic value, {
    double fallback = 0,
  }) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }

    return fallback;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
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

    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }

    return fallback;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  static bool _toBool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'true':
        case '1':
        case 'yes':
          return true;

        case 'false':
        case '0':
        case 'no':
          return false;
      }
    }

    return fallback;
  }
}
