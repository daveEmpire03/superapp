import '../../domain/entities/device_token_entity.dart';

class DeviceTokenModel extends DeviceTokenEntity {
  const DeviceTokenModel({
    required super.id,
    required super.token,
    required super.platform,
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  });

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) {
    return DeviceTokenModel(
      id: (json['id'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      platform: DevicePlatform.fromString(
        json['platform']?.toString(),
      ),
      isActive: json['is_active'] is bool ? json['is_active'] as bool : true,
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'platform': platform.value,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
