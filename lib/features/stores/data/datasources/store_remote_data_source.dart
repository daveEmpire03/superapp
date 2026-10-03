import 'package:bokku_mart/core/network/api_endpoints.dart';
import 'package:bokku_mart/core/network/dio_client.dart';
import 'package:bokku_mart/features/stores/data/model/store_model.dart';

abstract class StoreRemoteDataSource {
  Future<List<StoreModel>> getStores({
    double? latitude,
    double? longitude,
    String? search,
  });
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final DioClient dioClient;

  StoreRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<List<StoreModel>> getStores({
    double? latitude,
    double? longitude,
    String? search,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (latitude != null && longitude != null) {
      queryParameters['latitude'] = latitude;
      queryParameters['longitude'] = longitude;
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final response = await dioClient.get<dynamic>(
      ApiEndpoints.stores,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final data = response.data;

    // Supports:
    // [
    //   {...},
    //   {...}
    // ]
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (json) => StoreModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    }

    // Also supports paginated Django REST Framework responses:
    //
    // {
    //   "count": 20,
    //   "next": "...",
    //   "previous": null,
    //   "results": [...]
    // }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      final results = map['results'];

      if (results is List) {
        return results
            .whereType<Map>()
            .map(
              (json) => StoreModel.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();
      }
    }

    throw const FormatException(
      'Invalid stores response received from server.',
    );
  }
}
