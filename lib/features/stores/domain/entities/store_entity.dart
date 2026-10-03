import 'package:equatable/equatable.dart';

class StoreEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String? phoneNumber;

  final double? latitude;
  final double? longitude;

  /// Populated when the backend eventually returns distance-aware discovery.
  final double? distanceKm;

  final bool isActive;

  const StoreEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    this.phoneNumber,
    this.latitude,
    this.longitude,
    this.distanceKm,
    required this.isActive,
  });

  String get fullAddress {
    return [
      address,
      city,
      state,
    ].where((value) => value.trim().isNotEmpty).join(', ');
  }

  bool get hasCoordinates {
    return latitude != null && longitude != null;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        state,
        phoneNumber,
        latitude,
        longitude,
        distanceKm,
        isActive,
      ];
}
