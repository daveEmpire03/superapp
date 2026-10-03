import '../../domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.name,
    required super.address,
    required super.city,
    required super.state,
    super.phoneNumber,
    super.latitude,
    super.longitude,
    super.distanceKm,
    required super.isActive,
  });

  factory StoreModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StoreModel(
      id: _requiredString(
        json['id'],
        field: 'id',
      ),
      name: json['name']?.toString().trim() ?? '',
      address: json['address']?.toString().trim() ?? '',
      city: json['city']?.toString().trim() ?? '',
      state: json['state']?.toString().trim() ?? '',
      phoneNumber: _nullableString(
        json['phone_number'] ?? json['phone'],
      ),
      latitude: _toDouble(
        json['latitude'],
      ),
      longitude: _toDouble(
        json['longitude'],
      ),
      distanceKm: _toDouble(
        json['distance_km'],
      ),
      isActive: _toBool(
        json['is_active'],
        fallback: true,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'phone_number': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'distance_km': distanceKm,
      'is_active': isActive,
    };
  }

  static String _requiredString(
    dynamic value, {
    required String field,
  }) {
    final result = value?.toString().trim() ?? '';

    if (result.isEmpty) {
      throw FormatException(
        'Store response is missing required field "$field".',
      );
    }

    return result;
  }

  static String? _nullableString(
    dynamic value,
  ) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return null;
    }

    return result;
  }

  static double? _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static bool _toBool(
    dynamic value, {
    required bool fallback,
  }) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      if (value.toLowerCase() == 'true') {
        return true;
      }

      if (value.toLowerCase() == 'false') {
        return false;
      }
    }

    return fallback;
  }
}
