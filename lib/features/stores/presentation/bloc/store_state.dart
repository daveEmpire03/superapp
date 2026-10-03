import 'package:equatable/equatable.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/store_entity.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {
  const StoreInitial();
}

class StoreLoading extends StoreState {
  const StoreLoading();
}

class StoreLocationLoading extends StoreState {
  final List<StoreEntity> stores;
  final StoreEntity? selectedStore;

  const StoreLocationLoading({
    required this.stores,
    this.selectedStore,
  });

  @override
  List<Object?> get props => [
        stores,
        selectedStore,
      ];
}

class StoreLoaded extends StoreState {
  final List<StoreEntity> stores;
  final StoreEntity? selectedStore;

  /// Optional, non-blocking message related to device location.
  final String? locationMessage;

  /// Identifies the specific location problem so the UI can
  /// provide the correct action without parsing message strings.
  final LocationExceptionType? locationExceptionType;

  const StoreLoaded({
    required this.stores,
    this.selectedStore,
    this.locationMessage,
    this.locationExceptionType,
  });

  StoreLoaded copyWith({
    List<StoreEntity>? stores,
    StoreEntity? selectedStore,
    String? locationMessage,
    LocationExceptionType? locationExceptionType,
    bool clearLocationMessage = false,
    bool clearLocationExceptionType = false,
  }) {
    return StoreLoaded(
      stores: stores ?? this.stores,
      selectedStore: selectedStore ?? this.selectedStore,
      locationMessage:
          clearLocationMessage ? null : locationMessage ?? this.locationMessage,
      locationExceptionType: clearLocationExceptionType
          ? null
          : locationExceptionType ?? this.locationExceptionType,
    );
  }

  @override
  List<Object?> get props => [
        stores,
        selectedStore,
        locationMessage,
        locationExceptionType,
      ];
}

class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object?> get props => [
        message,
      ];
}
