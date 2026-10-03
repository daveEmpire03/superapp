import 'package:equatable/equatable.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<CategoryEntity> categories;
  final List<ProductEntity> deals;
  final List<ProductEntity> allProducts;
  final String? selectedCategory;
  final List<ProductEntity> filteredProducts;
  final List<ProductEntity> searchResults;
  final bool isSearching;

  const ProductLoaded({
    required this.categories,
    required this.deals,
    required this.allProducts,
    this.selectedCategory,
    required this.filteredProducts,
    this.searchResults = const [],
    this.isSearching = false,
  });

  ProductLoaded copyWith({
    List<CategoryEntity>? categories,
    List<ProductEntity>? deals,
    List<ProductEntity>? allProducts,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    List<ProductEntity>? filteredProducts,
    List<ProductEntity>? searchResults,
    bool? isSearching,
  }) {
    return ProductLoaded(
      categories: categories ?? this.categories,
      deals: deals ?? this.deals,
      allProducts: allProducts ?? this.allProducts,
      selectedCategory: clearSelectedCategory
          ? null
          : selectedCategory ?? this.selectedCategory,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        deals,
        allProducts,
        selectedCategory,
        filteredProducts,
        searchResults,
        isSearching,
      ];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
