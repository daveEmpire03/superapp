import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/store_entity.dart';

class StoreSelection {
  final List<StoreEntity> stores;
  final String? selectedStoreId;
  const StoreSelection(this.stores, this.selectedStoreId);

  StoreEntity? get selectedStore {
    for (final store in stores) {
      if (store.id == selectedStoreId) return store;
    }
    return null;
  }
}

final storesControllerProvider =
    AsyncNotifierProvider<StoresController, StoreSelection>(StoresController.new);

class StoresController extends AsyncNotifier<StoreSelection> {
  @override
  Future<StoreSelection> build() async {
    final repo = ref.read(storeRepositoryProvider);
    final stores = await repo.getStores();
    return StoreSelection(stores, repo.getSelectedStoreId());
  }

  Future<void> search(String query) async {
    final previous = state;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final repo = ref.read(storeRepositoryProvider);
      final stores = await repo.getStores(search: query.trim());
      return StoreSelection(stores, repo.getSelectedStoreId());
    });
    state = result.hasError && previous.hasValue ? previous : result;
  }

  Future<void> selectStore(String storeId) async {
    final current = await future;
    if (!current.stores.any((store) => store.id == storeId)) {
      throw StateError('Store must be available in the current store list.');
    }
    await ref.read(storeRepositoryProvider).saveSelectedStoreId(storeId);
    state = AsyncData(StoreSelection(current.stores, storeId));
    // Catalog consumers read the store-specific family; switching never mixes prices.
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}
