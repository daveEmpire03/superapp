import '../../domain/entities/store_entity.dart';
import '../datasources/store_local_data_source.dart';
import '../datasources/store_remote_data_source.dart';
import 'store_repository.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;
  final StoreLocalDataSource localDataSource;

  StoreRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<StoreEntity>> getStores({
    double? latitude,
    double? longitude,
    String? search,
  }) {
    return remoteDataSource.getStores(
      latitude: latitude,
      longitude: longitude,
      search: search,
    );
  }

  @override
  String? getSelectedStoreId() {
    return localDataSource.getSelectedStoreId();
  }

  @override
  Future<void> saveSelectedStoreId(
    String storeId,
  ) {
    return localDataSource.saveSelectedStoreId(
      storeId,
    );
  }

  @override
  Future<void> clearSelectedStoreId() {
    return localDataSource.clearSelectedStoreId();
  }
}
