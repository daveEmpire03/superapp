import 'package:equatable/equatable.dart';

class StoreLocationEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String area;
  final String distance;
  final String openingHours;
  final bool isOpen;
  final String phone;
  final List<String> services;

  const StoreLocationEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.area,
    required this.distance,
    required this.openingHours,
    required this.isOpen,
    required this.phone,
    required this.services,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        area,
        distance,
        openingHours,
        isOpen,
        phone,
        services,
      ];
}
