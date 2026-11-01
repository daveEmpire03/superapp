import 'package:equatable/equatable.dart';

enum DevicePlatform {
  android('ANDROID', 'Android'),
  ios('IOS', 'iOS'),
  web('WEB', 'Web');

  final String value;
  final String label;

  const DevicePlatform(this.value, this.label);

  static DevicePlatform fromString(String? platform) {
    if (platform == null) return DevicePlatform.android;
    final normalized = platform.trim().toUpperCase();
    for (final p in DevicePlatform.values) {
      if (p.value == normalized) return p;
    }
    return DevicePlatform.android;
  }
}

class DeviceTokenEntity extends Equatable {
  final String id;
  final String token;
  final DevicePlatform platform;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeviceTokenEntity({
    required this.id,
    required this.token,
    required this.platform,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        token,
        platform,
        isActive,
        createdAt,
        updatedAt,
      ];
}
