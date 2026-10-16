import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/rider_job_entity.dart';
import '../models/rider_job_model.dart';

abstract class RiderRemoteDataSource {
  Future<List<RiderJobModel>> getMyDeliveries();

  Future<RiderJobModel> updateStatus({
    required String deliveryId,
    required DeliveryStatus status,
    String? note,
    String? proofNote,
  });
}

class RiderRemoteDataSourceImpl implements RiderRemoteDataSource {
  final DioClient dioClient;

  RiderRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<RiderJobModel>> getMyDeliveries() async {
    final response = await dioClient.get<dynamic>(ApiEndpoints.riderDeliveries);

    final data = response.data;

    // DRF paginated response → {"count": N, "results": [...]}
    // Non-paginated → [...]
    final List<dynamic> list;
    if (data is Map && data['results'] is List) {
      list = data['results'] as List;
    } else if (data is List) {
      list = data;
    } else {
      throw const ServerException(
        message: 'Invalid rider deliveries response from server.',
      );
    }

    return list
        .whereType<Map>()
        .map((e) => RiderJobModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  @override
  Future<RiderJobModel> updateStatus({
    required String deliveryId,
    required DeliveryStatus status,
    String? note,
    String? proofNote,
  }) async {
    final response = await dioClient.patch<dynamic>(
      ApiEndpoints.riderDeliveryStatus(deliveryId),
      data: {
        'status': status.wire,
        if (note != null && note.isNotEmpty) 'note': note,
        if (proofNote != null && proofNote.isNotEmpty) 'proof_note': proofNote,
      },
    );

    final data = response.data;

    if (data is! Map) {
      throw const ServerException(
        message: 'Invalid status update response from server.',
      );
    }

    return RiderJobModel.fromJson(Map<String, dynamic>.from(data));
  }
}
