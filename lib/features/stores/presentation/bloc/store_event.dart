import 'package:equatable/equatable.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

class LoadStoresEvent extends StoreEvent {
  final double? latitude;
  final double? longitude;

  const LoadStoresEvent({
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
      ];
}

class LoadStoresWithLocationEvent extends StoreEvent {
  const LoadStoresWithLocationEvent();
}

class SearchStoresEvent extends StoreEvent {
  final String query;
  final double? latitude;
  final double? longitude;

  const SearchStoresEvent({
    required this.query,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        query,
        latitude,
        longitude,
      ];
}

class SelectStoreEvent extends StoreEvent {
  final String storeId;

  const SelectStoreEvent(
    this.storeId,
  );

  @override
  List<Object?> get props => [
        storeId,
      ];
}
