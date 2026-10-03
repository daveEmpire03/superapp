import '../../domain/entities/store_entity.dart';

abstract class StoreRepository {
  Future<List<StoreEntity>> getStores({
    double? latitude,
    double? longitude,
    String? search,
  });

  String? getSelectedStoreId();

  Future<void> saveSelectedStoreId(
    String storeId,
  );

  Future<void> clearSelectedStoreId();
}
