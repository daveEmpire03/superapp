import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadCatalogEvent extends ProductEvent {
  final String? storeId;

  const LoadCatalogEvent({
    this.storeId,
  });

  @override
  List<Object?> get props => [
        storeId,
      ];
}

class FilterByCategoryEvent extends ProductEvent {
  final String categoryId;

  const FilterByCategoryEvent(
    this.categoryId,
  );

  @override
  List<Object?> get props => [
        categoryId,
      ];
}

class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent(
    this.query,
  );

  @override
  List<Object?> get props => [
        query,
      ];
}

class ClearSearchEvent extends ProductEvent {
  const ClearSearchEvent();
}
