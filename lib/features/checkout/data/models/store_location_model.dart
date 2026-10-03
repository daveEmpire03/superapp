import '../../domain/entities/store_location_entity.dart';

class StoreLocationModel extends StoreLocationEntity {
  const StoreLocationModel({
    required super.id,
    required super.name,
    required super.address,
    required super.city,
    required super.area,
    required super.distance,
    required super.openingHours,
    required super.isOpen,
    required super.phone,
    required super.services,
  });

  factory StoreLocationModel.fromJson(Map<String, dynamic> json) {
    return StoreLocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String? ?? 'Lagos',
      area: json['area'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      openingHours: json['openingHours'] as String? ?? '8:00 AM - 9:00 PM',
      isOpen: json['isOpen'] as bool? ?? true,
      phone: json['phone'] as String? ?? '',
      services:
          (json['services'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'area': area,
      'distance': distance,
      'openingHours': openingHours,
      'isOpen': isOpen,
      'phone': phone,
      'services': services,
    };
  }
}
