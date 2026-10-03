import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<CategoryEntity>> getCategories();

  Future<List<ProductEntity>> getFeaturedDeals({
    String? storeId,
  });

  Future<List<ProductEntity>> getAllProducts({
    String? storeId,
  });

  Future<List<ProductEntity>> getProductsByCategory(
    String categoryId, {
    String? storeId,
  });

  Future<ProductEntity> getProductById(
    String id, {
    String? storeId,
  });

  Future<List<ProductEntity>> searchProducts(
    String query, {
    String? storeId,
  });
}
