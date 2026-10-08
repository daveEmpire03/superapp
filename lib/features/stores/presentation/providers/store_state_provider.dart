import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/repositories/store_repository.dart';
import '../bloc/store_event.dart';
import '../bloc/store_state.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/location/location_service.dart';
import '../../domain/entities/store_entity.dart';

typedef Emitter<T> = void Function(T value);

final storeStateProvider = NotifierProvider<StoreController, StoreState>(
  StoreController.new,
);

class StoreController extends Notifier<StoreState> {
  StoreRepository get storeRepository => ref.read(storeRepositoryProvider);
  LocationService get locationService => ref.read(locationServiceProvider);
  StoreEntity? _selectedStore;
  double? _currentLatitude;
  double? _currentLongitude;

  @override
  StoreState build() => const StoreInitial();

  void _emit(StoreState value) { state = value; }

  Future<void> add(StoreEvent event) async {
    if (event is LoadStoresEvent) {
      await _onLoadStores(event, _emit);
    }     else if (event is LoadStoresWithLocationEvent) {
      await _onLoadStoresWithLocation(event, _emit);
    }     else if (event is SearchStoresEvent) {
      await _onSearchStores(event, _emit);
    }     else if (event is SelectStoreEvent) {
      await _onSelectStore(event, _emit);
    }
  }

  Future<void> _onLoadStores(
    LoadStoresEvent event,
    Emitter<StoreState> emit,
  ) async {
    emit(const StoreLoading());

    try {
      final stores = await storeRepository.getStores(
        latitude: event.latitude ?? _currentLatitude,
        longitude: event.longitude ?? _currentLongitude,
      );

      _restoreSelectedStore(
        stores,
      );

      emit(
        StoreLoaded(
          stores: stores,
          selectedStore: _selectedStore,
        ),
      );
    } catch (error) {
      emit(
        StoreError(
          _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onLoadStoresWithLocation(
    LoadStoresWithLocationEvent event,
    Emitter<StoreState> emit,
  ) async {
    final currentState = state;

    List<StoreEntity> existingStores = const [];

    StoreEntity? existingSelectedStore;

    if (currentState is StoreLoaded) {
      existingStores = currentState.stores;
      existingSelectedStore = currentState.selectedStore;

      emit(
        StoreLocationLoading(
          stores: existingStores,
          selectedStore: existingSelectedStore,
        ),
      );
    }

    try {
      final location = await locationService.getCurrentLocation();

      _currentLatitude = location.latitude;
      _currentLongitude = location.longitude;

      final stores = await storeRepository.getStores(
        latitude: _currentLatitude,
        longitude: _currentLongitude,
      );

      _restoreSelectedStore(
        stores,
      );

      emit(
        StoreLoaded(
          stores: stores,
          selectedStore: _selectedStore,
        ),
      );
    } on LocationException catch (error) {
      // Location is optional. Existing stores remain usable.
      if (existingStores.isNotEmpty) {
        emit(
          StoreLoaded(
            stores: existingStores,
            selectedStore: existingSelectedStore,
            locationMessage: error.message,
            locationExceptionType: error.type,
          ),
        );

        return;
      }

      try {
        final stores = await storeRepository.getStores();

        _restoreSelectedStore(
          stores,
        );

        emit(
          StoreLoaded(
            stores: stores,
            selectedStore: _selectedStore,
            locationMessage: error.message,
            locationExceptionType: error.type,
          ),
        );
      } catch (storeError) {
        emit(
          StoreError(
            _errorMessage(
              storeError,
            ),
          ),
        );
      }
    } catch (error) {
      emit(
        StoreError(
          _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onSearchStores(
    SearchStoresEvent event,
    Emitter<StoreState> emit,
  ) async {
    emit(const StoreLoading());

    try {
      final stores = await storeRepository.getStores(
        latitude: event.latitude ?? _currentLatitude,
        longitude: event.longitude ?? _currentLongitude,
        search: event.query.trim(),
      );

      _restoreSelectedStore(
        stores,
      );

      emit(
        StoreLoaded(
          stores: stores,
          selectedStore: _selectedStore,
        ),
      );
    } catch (error) {
      emit(
        StoreError(
          _errorMessage(error),
        ),
      );
    }
  }

  Future<void> _onSelectStore(
    SelectStoreEvent event,
    Emitter<StoreState> emit,
  ) async {
    final currentState = state;

    List<StoreEntity> stores;

    String? locationMessage;
    LocationExceptionType? locationExceptionType;

    if (currentState is StoreLoaded) {
      stores = currentState.stores;
      locationMessage = currentState.locationMessage;
      locationExceptionType = currentState.locationExceptionType;
    } else if (currentState is StoreLocationLoading) {
      stores = currentState.stores;
    } else {
      return;
    }

    StoreEntity? selectedStore;

    for (final store in stores) {
      if (store.id == event.storeId) {
        selectedStore = store;
        break;
      }
    }

    if (selectedStore == null) {
      return;
    }

    try {
      await storeRepository.saveSelectedStoreId(
        selectedStore.id,
      );

      _selectedStore = selectedStore;

      emit(
        StoreLoaded(
          stores: stores,
          selectedStore: selectedStore,
          locationMessage: locationMessage,
          locationExceptionType: locationExceptionType,
        ),
      );
    } catch (error) {
      emit(
        StoreError(
          _errorMessage(error),
        ),
      );
    }
  }

  void _restoreSelectedStore(
    List<StoreEntity> stores,
  ) {
    final selectedId =
        _selectedStore?.id ?? storeRepository.getSelectedStoreId();

    if (selectedId == null) {
      _selectedStore = null;
      return;
    }

    for (final store in stores) {
      if (store.id == selectedId) {
        _selectedStore = store;
        return;
      }
    }

    // Do not delete the persisted ID here.
    // A search result can contain only a subset of stores.
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

    if (error is CacheException) {
      return error.message;
    }

    if (error is LocationException) {
      return error.message;
    }

    if (error is FormatException) {
      return error.message;
    }

    return 'Unable to load stores. Please try again.';
  }
}
