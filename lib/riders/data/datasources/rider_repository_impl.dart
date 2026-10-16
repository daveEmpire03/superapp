import 'package:bokku_mart/riders/repositories/rider_repository.dart';

import '../../domain/entities/rider_job_entity.dart';
import '../datasources/rider_remote_data_source.dart';

class RiderRepositoryImpl implements RiderRepository {
  final RiderRemoteDataSource remoteDataSource;

  RiderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RiderJobEntity>> getMyDeliveries() {
    return remoteDataSource.getMyDeliveries();
  }

  @override
  Future<RiderJobEntity> updateStatus({
    required String deliveryId,
    required DeliveryStatus status,
    String? note,
    String? proofNote,
  }) {
    return remoteDataSource.updateStatus(
      deliveryId: deliveryId,
      status: status,
      note: note,
      proofNote: proofNote,
    );
  }
}
