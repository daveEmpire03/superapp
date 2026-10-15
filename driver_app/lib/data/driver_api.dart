import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DriverApi {
  DriverApi()
      : _storage = const FlutterSecureStorage(),
        _dio = Dio(BaseOptions(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://127.0.0.1:8000/api/v1/',
          ),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 15),
          headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  final FlutterSecureStorage _storage;
  final Dio _dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('auth/login/', data: {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    final data = Map<String, dynamic>.from(response.data as Map);
    final user = Map<String, dynamic>.from(data['user'] as Map);
    if (user['role'] != 'RIDER') {
      throw StateError('This account is not registered as a driver.');
    }
    await _storage.write(key: 'access', value: data['access']?.toString());
    await _storage.write(key: 'refresh', value: data['refresh']?.toString());
    return user;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access');
    await _storage.delete(key: 'refresh');
  }

  Future<Map<String, dynamic>> profile() async =>
      Map<String, dynamic>.from((await _dio.get('rides/driver/profile/')).data['data'] as Map);

  Future<Map<String, dynamic>> createProfile({
    required String vehicleType,
    required String plate,
    required String make,
    required String color,
  }) async {
    final response = await _dio.post('rides/driver/profile/', data: {
      'vehicle_type': vehicleType,
      'vehicle_plate': plate.trim().toUpperCase(),
      'vehicle_make': make.trim(),
      'vehicle_color': color.trim(),
    });
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    await _dio.post('rides/driver/location/', data: {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<Map<String, dynamic>> setAvailability(bool available) async {
    final response = await _dio.post('rides/driver/availability/', data: {
      'is_available': available,
    });
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }

  Future<List<Map<String, dynamic>>> availableRides() async =>
      _items((await _dio.get('rides/driver/available/')).data['data']);

  Future<List<Map<String, dynamic>>> myRides() async =>
      _items((await _dio.get('rides/driver/mine/')).data['results'] ?? (await _dio.get('rides/driver/mine/')).data);

  Future<List<Map<String, dynamic>>> availableParcels() async =>
      _items((await _dio.get('parcels/driver/available/')).data['data']);

  Future<List<Map<String, dynamic>>> myParcels() async =>
      _items((await _dio.get('parcels/driver/mine/')).data['results'] ?? (await _dio.get('parcels/driver/mine/')).data);

  List<Map<String, dynamic>> _items(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> acceptRide(String id) async =>
      _dio.post('rides/$id/accept/', data: const {});

  Future<void> updateRideStatus(String id, String status) async =>
      _dio.post('rides/$id/status/', data: {'status': status});

  Future<void> acceptParcel(String id) async =>
      _dio.post('parcels/$id/accept/', data: const {});

  Future<void> updateParcelStatus(
    String id,
    String status, {
    String? deliveryCode,
    String? proofNote,
  }) async {
    await _dio.patch('parcels/$id/status/', data: {
      'status': status,
      if (deliveryCode != null) 'delivery_code': deliveryCode,
      if (proofNote != null && proofNote.isNotEmpty) 'proof_note': proofNote,
    });
  }
}
