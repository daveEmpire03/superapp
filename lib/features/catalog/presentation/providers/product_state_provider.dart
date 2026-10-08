import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/product_repository.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../../../core/error/exceptions.dart';

typedef Emitter<T> = void Function(T value);

final productStateProvider = NotifierProvider<ProductController, ProductState>(
  ProductController.new,
);

class ProductController extends Notifier<ProductState> {
  ProductRepository get productRepository => ref.read(productRepositoryProvider);
  String? _selectedStoreId;
  String? get selectedStoreId => _selectedStoreId;

  @override
  ProductState build() => const ProductInitial();

  void _emit(ProductState value) { state = value; }

  Future<void> add(ProductEvent event) async {
    if (event is LoadCatalogEvent) {
      await _onLoadCatalog(event, _emit);
    }     else if (event is FilterByCategoryEvent) {
      await _onFilterByCategory(event, _emit);
    }     else if (event is SearchProductsEvent) {
      await _onSearchProducts(event, _emit);
    }     else if (event is ClearSearchEvent) {
      _onClearSearch(event, _emit);
    }
  }

  Future<void> _onLoadCatalog(
    LoadCatalogEvent event,
    Emitter<ProductState> emit,
  ) async {
    _selectedStoreId = event.storeId;

    emit(const ProductLoading());

    try {
      final categories = await productRepository.getCategories();

      final deals = await productRepository.getFeaturedDeals(
        storeId: _selectedStoreId,
      );

      final allProducts = await productRepository.getAllProducts(
        storeId: _selectedStoreId,
      );

      emit(
        ProductLoaded(
          categories: categories,
          deals: deals,
          allProducts: allProducts,
          filteredProducts: allProducts,
        ),
      );
    } catch (error) {
      emit(
        ProductError(
          _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;

    if (currentState is! ProductLoaded) {
      return;
    }

    if (currentState.selectedCategory == event.categoryId) {
      emit(
        currentState.copyWith(
          clearSelectedCategory: true,
          filteredProducts: currentState.allProducts,
        ),
      );

      return;
    }

    final filtered = currentState.allProducts.where(
      (product) {
        return product.category.toLowerCase() == event.categoryId.toLowerCase();
      },
    ).toList();

    emit(
      currentState.copyWith(
        selectedCategory: event.categoryId,
        filteredProducts: filtered,
      ),
    );
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;

    if (currentState is! ProductLoaded) {
      return;
    }

    final query = event.query.trim();

    if (query.isEmpty) {
      emit(
        currentState.copyWith(
          searchResults: const [],
          isSearching: false,
        ),
      );

      return;
    }

    emit(
      currentState.copyWith(
        isSearching: true,
      ),
    );

    try {
      final results = await productRepository.searchProducts(
        query,
        storeId: _selectedStoreId,
      );

      final latestState = state;

      if (latestState is ProductLoaded) {
        emit(
          latestState.copyWith(
            searchResults: results,
            isSearching: false,
          ),
        );
      }
    } catch (error) {
      // Search failure should not destroy the already-loaded catalog.
      final latestState = state;

      if (latestState is ProductLoaded) {
        emit(
          latestState.copyWith(
            isSearching: false,
          ),
        );
      }
    }
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<ProductState> emit,
  ) {
    final currentState = state;

    if (currentState is ProductLoaded) {
      emit(
        currentState.copyWith(
          searchResults: const [],
          isSearching: false,
        ),
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
