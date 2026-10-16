import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/product_repository.dart';
import '../bloc/product_state.dart';
import '../../../../core/error/exceptions.dart';

final productStateProvider = NotifierProvider<ProductController, ProductState>(
  ProductController.new,
);

class ProductController extends Notifier<ProductState> {
  ProductRepository get productRepository => ref.read(productRepositoryProvider);
  String? _selectedStoreId;
  String? get selectedStoreId => _selectedStoreId;

  @override
  ProductState build() => const ProductInitial();

  Future<void> loadCatalog({String? storeId}) async {
    _selectedStoreId = storeId;

    state = const ProductLoading();

    try {
      final categories = await productRepository.getCategories();

      final deals = await productRepository.getFeaturedDeals(
        storeId: _selectedStoreId,
      );

      final allProducts = await productRepository.getAllProducts(
        storeId: _selectedStoreId,
      );

      state = ProductLoaded(
        categories: categories,
        deals: deals,
        allProducts: allProducts,
        filteredProducts: allProducts,
      );
    } catch (error) {
      state = ProductError(
        _errorMessage(error),
      );
    }
  }

  void filterByCategory(String categoryId) {
    final currentState = state;

    if (currentState is! ProductLoaded) {
      return;
    }

    if (currentState.selectedCategory == categoryId) {
      state = currentState.copyWith(
        clearSelectedCategory: true,
        filteredProducts: currentState.allProducts,
      );

      return;
    }

    final filtered = currentState.allProducts.where(
      (product) {
        return product.category.toLowerCase() == categoryId.toLowerCase();
      },
    ).toList();

    state = currentState.copyWith(
      selectedCategory: categoryId,
      filteredProducts: filtered,
    );
  }

  Future<void> searchProducts(String query) async {
    final currentState = state;

    if (currentState is! ProductLoaded) {
      return;
    }

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      state = currentState.copyWith(
        searchResults: const [],
        isSearching: false,
      );

      return;
    }

    state = currentState.copyWith(
      isSearching: true,
    );

    try {
      final results = await productRepository.searchProducts(
        trimmedQuery,
        storeId: _selectedStoreId,
      );

      final latestState = state;

      if (latestState is ProductLoaded) {
        state = latestState.copyWith(
          searchResults: results,
          isSearching: false,
        );
      }
    } catch (error) {
      // Search failure should not destroy the already-loaded catalog.
      final latestState = state;

      if (latestState is ProductLoaded) {
        state = latestState.copyWith(
          isSearching: false,
        );
      }
    }
  }

  void clearSearch() {
    final currentState = state;

    if (currentState is ProductLoaded) {
      state = currentState.copyWith(
        searchResults: const [],
        isSearching: false,
      );
    }
  }



  String _errorMessage(
    Object error,
  ) {
    if (error is ServerException) {
      return error.message;
    }

    if (error is NetworkException) {
      return error.message;
    }

    if (error is FormatException) {
      return error.message;
    }

    return 'Unable to load the catalog. Please try again.';
  }
}
