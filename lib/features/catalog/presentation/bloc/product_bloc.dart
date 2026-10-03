import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  String? _selectedStoreId;

  String? get selectedStoreId => _selectedStoreId;

  ProductBloc({
    required this.productRepository,
  }) : super(const ProductInitial()) {
    on<LoadCatalogEvent>(
      _onLoadCatalog,
    );

    on<FilterByCategoryEvent>(
      _onFilterByCategory,
    );

    on<SearchProductsEvent>(
      _onSearchProducts,
    );

    on<ClearSearchEvent>(
      _onClearSearch,
    );
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
