import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<CategoryEntity>> getCategories() {
    return remoteDataSource.getCategories();
  }

  @override
  Future<List<ProductEntity>> getFeaturedDeals({
    String? storeId,
  }) {
    return remoteDataSource.getFeaturedDeals(
      storeId: storeId,
    );
  }

  @override
  Future<List<ProductEntity>> getAllProducts({
    String? storeId,
  }) {
    return remoteDataSource.getAllProducts(
      storeId: storeId,
    );
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(
    String categoryId, {
    String? storeId,
  }) {
    return remoteDataSource.getProductsByCategory(
      categoryId,
      storeId: storeId,
    );
  }

  @override
  Future<ProductEntity> getProductById(
    String id, {
    String? storeId,
  }) {
    return remoteDataSource.getProductById(
      id,
      storeId: storeId,
    );
  }

  @override
  Future<List<ProductEntity>> searchProducts(
    String query, {
    String? storeId,
  }) {
    return remoteDataSource.searchProducts(
      query,
      storeId: storeId,
    );
  }
}
