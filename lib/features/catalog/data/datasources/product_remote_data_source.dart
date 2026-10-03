import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<List<ProductModel>> getFeaturedDeals({
    String? storeId,
  });

  Future<List<ProductModel>> getAllProducts({
    String? storeId,
  });

  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    String? storeId,
  });

  Future<ProductModel> getProductById(
    String id, {
    String? storeId,
  });

  Future<List<ProductModel>> searchProducts(
    String query, {
    String? storeId,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;

  ProductRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dioClient.get<dynamic>(
      ApiEndpoints.categories,
    );

    return _parseCategoryList(
      response.data,
    );
  }

  @override
  Future<List<ProductModel>> getFeaturedDeals({
    String? storeId,
  }) async {
    final response = await dioClient.get<dynamic>(
      ApiEndpoints.deals,
      queryParameters: _storeQuery(storeId),
    );

    return _parseProductList(
      response.data,
    );
  }

  @override
  Future<List<ProductModel>> getAllProducts({
    String? storeId,
  }) async {
    final response = await dioClient.get<dynamic>(
      ApiEndpoints.products,
      queryParameters: _storeQuery(storeId),
    );

    return _parseProductList(
      response.data,
    );
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    String? storeId,
  }) async {
    final response = await dioClient.get<dynamic>(
      ApiEndpoints.products,
      queryParameters: {
        'category': categoryId,
        if (storeId != null) 'store_id': storeId,
      },
    );

    return _parseProductList(
      response.data,
    );
  }

  @override
  Future<ProductModel> getProductById(
    String id, {
    String? storeId,
  }) async {
    final response = await dioClient.get<dynamic>(
      ApiEndpoints.productDetail(id),
      queryParameters: _storeQuery(storeId),
    );

    final data = response.data;

    if (data is! Map) {
      throw const FormatException(
        'Invalid product response received from server.',
      );
    }

    return ProductModel.fromJson(
      Map<String, dynamic>.from(
        data,
      ),
    );
  }

  @override
  Future<List<ProductModel>> searchProducts(
    String query, {
    String? storeId,
  }) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return [];
    }

    final response = await dioClient.get<dynamic>(
      ApiEndpoints.search,
      queryParameters: {
        'q': trimmedQuery,
        if (storeId != null) 'store_id': storeId,
      },
    );

    return _parseProductList(
      response.data,
    );
  }

  Map<String, dynamic>? _storeQuery(
    String? storeId,
  ) {
    if (storeId == null || storeId.trim().isEmpty) {
      return null;
    }

    return {
      'store_id': storeId,
    };
  }

  List<ProductModel> _parseProductList(
    dynamic data,
  ) {
    final items = _extractList(
      data,
    );

    return items
        .whereType<Map>()
        .map(
          (item) => ProductModel.fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        )
        .toList();
  }

  List<CategoryModel> _parseCategoryList(
    dynamic data,
  ) {
    final items = _extractList(
      data,
    );

    return items
        .whereType<Map>()
        .map(
          (item) => CategoryModel.fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        )
        .toList();
  }

  List<dynamic> _extractList(
    dynamic data,
  ) {
    if (data is List) {
      return data;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(
        data,
      );

      final results = map['results'];

      if (results is List) {
        return results;
      }
    }

    throw const FormatException(
      'Expected a list response or a paginated results response.',
    );
  }
}
