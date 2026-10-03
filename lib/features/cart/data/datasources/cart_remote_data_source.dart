import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();

  Future<CartModel> addItem({
    required String inventoryId,
    int quantity = 1,
  });

  Future<CartModel> updateQuantity({
    required String cartItemId,
    required int quantity,
  });

  Future<CartModel> removeItem({
    required String cartItemId,
  });

  Future<CartModel> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioClient dioClient;

  CartRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<CartModel> getCart() async {
    final response = await dioClient.get<dynamic>(
      ApiEndpoints.cart,
    );

    return _parseCartResponse(
      response.data,
    );
  }

  @override
  Future<CartModel> addItem({
    required String inventoryId,
    int quantity = 1,
  }) async {
    final normalizedInventoryId = inventoryId.trim();

    if (normalizedInventoryId.isEmpty) {
      throw ArgumentError(
        'inventoryId cannot be empty.',
      );
    }

    if (quantity <= 0) {
      throw ArgumentError(
        'quantity must be greater than zero.',
      );
    }

    final response = await dioClient.post<dynamic>(
      ApiEndpoints.cartItems,
      data: {
        'inventory_id': normalizedInventoryId,
        'quantity': quantity,
      },
    );

    return _parseCartResponse(
      response.data,
    );
  }

  @override
  Future<CartModel> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    final normalizedCartItemId = cartItemId.trim();

    if (normalizedCartItemId.isEmpty) {
      throw ArgumentError(
        'cartItemId cannot be empty.',
      );
    }

    if (quantity <= 0) {
      throw ArgumentError(
        'quantity must be greater than zero.',
      );
    }

    final response = await dioClient.patch<dynamic>(
      ApiEndpoints.cartItem(
        normalizedCartItemId,
      ),
      data: {
        'quantity': quantity,
      },
    );

    return _parseCartResponse(
      response.data,
    );
  }

  @override
  Future<CartModel> removeItem({
    required String cartItemId,
  }) async {
    final normalizedCartItemId = cartItemId.trim();

    if (normalizedCartItemId.isEmpty) {
      throw ArgumentError(
        'cartItemId cannot be empty.',
      );
    }

    final response = await dioClient.delete<dynamic>(
      ApiEndpoints.removeCartItem(
        normalizedCartItemId,
      ),
    );

    return _parseCartResponse(
      response.data,
    );
  }

  @override
  Future<CartModel> clearCart() async {
    final response = await dioClient.delete<dynamic>(
      ApiEndpoints.clearCart,
    );

    /// The current Django clear-cart endpoint returns:
    ///
    /// {
    ///   "success": true,
    ///   "message": "Cart cleared successfully."
    /// }
    ///
    /// It does not currently return CartSerializer data.
    ///
    /// If the backend later starts returning the updated cart,
    /// we can use it immediately without making another request.
    final cart = _tryParseCartResponse(
      response.data,
    );

    if (cart != null) {
      return cart;
    }

    /// Fetch the now-empty authoritative cart from Django.
    return getCart();
  }

  CartModel _parseCartResponse(dynamic data) {
    final cart = _tryParseCartResponse(data);

    if (cart != null) {
      return cart;
    }

    throw const FormatException(
      'Cart data was not found in the server response.',
    );
  }

  CartModel? _tryParseCartResponse(dynamic data) {
    if (data is! Map) {
      return null;
    }

    final responseMap = Map<String, dynamic>.from(
      data,
    );

    /// Wrapped API response:
    ///
    /// {
    ///   "success": true,
    ///   "message": "...",
    ///   "data": {
    ///     ...cart...
    ///   }
    /// }
    final nestedData = responseMap['data'];

    if (nestedData is Map) {
      final dataMap = Map<String, dynamic>.from(
        nestedData,
      );

      if (_looksLikeCart(dataMap)) {
        return CartModel.fromJson(
          dataMap,
        );
      }

      final nestedCart = dataMap['cart'];

      if (nestedCart is Map) {
        return CartModel.fromJson(
          Map<String, dynamic>.from(
            nestedCart,
          ),
        );
      }
    }

    /// Direct CartSerializer response.
    if (_looksLikeCart(responseMap)) {
      return CartModel.fromJson(
        responseMap,
      );
    }

    /// Defensive support for:
    ///
    /// {
    ///   "cart": {
    ///     ...cart...
    ///   }
    /// }
    final nestedCart = responseMap['cart'];

    if (nestedCart is Map) {
      return CartModel.fromJson(
        Map<String, dynamic>.from(
          nestedCart,
        ),
      );
    }

    return null;
  }

  bool _looksLikeCart(
    Map<String, dynamic> json,
  ) {
    return json.containsKey('id') &&
        json.containsKey('items') &&
        json.containsKey('subtotal');
  }
}
