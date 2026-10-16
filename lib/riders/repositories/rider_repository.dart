import 'package:bokku_mart/riders/domain/entities/rider_job_entity.dart';

abstract class RiderRepository {
  /// All deliveries assigned to the current rider.
  Future<List<RiderJobEntity>> getMyDeliveries();

  /// Advance (or reject) a delivery status.
  Future<RiderJobEntity> updateStatus({
    required String deliveryId,
    required DeliveryStatus status,
    String? note,
    String? proofNote,
  });
}
