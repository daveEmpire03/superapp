import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

class CatalogSnapshot {
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;
  final List<ProductEntity> deals;
  const CatalogSnapshot({
    required this.categories,
    required this.products,
    required this.deals,
  });
}

// Different stores must never share the same inventory/pricing cache.
final catalogProvider = FutureProvider.family<CatalogSnapshot, String?>((ref, storeId) async {
  final repository = ref.watch(productRepositoryProvider);
  final results = await Future.wait<Object>([
    repository.getCategories(),
    repository.getAllProducts(storeId: storeId),
    repository.getFeaturedDeals(storeId: storeId),
  ]);
  return CatalogSnapshot(
    categories: results[0] as List<CategoryEntity>,
    products: results[1] as List<ProductEntity>,
    deals: results[2] as List<ProductEntity>,
  );
});

typedef ProductSearchKey = ({String query, String? storeId});

final productSearchProvider =
    FutureProvider.family<List<ProductEntity>, ProductSearchKey>((ref, key) {
  final query = key.query.trim();
  if (query.isEmpty) return Future.value(<ProductEntity>[]);
  return ref.watch(productRepositoryProvider).searchProducts(
    query, storeId: key.storeId);
});

final productDetailProvider =
    FutureProvider.family<ProductEntity, ({String id, String? storeId})>((ref, key) {
  return ref.watch(productRepositoryProvider).getProductById(
    key.id, storeId: key.storeId);
});
