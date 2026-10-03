import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String id;
  final String label; // Home, Work, Other
  final String fullName;
  final String phoneNumber;
  final String state;
  final String city;
  final String area;
  final String streetAddress;
  final String landmark;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phoneNumber,
    required this.state,
    required this.city,
    required this.area,
    required this.streetAddress,
    required this.landmark,
    this.isDefault = false,
  });

  String get fullDisplayAddress =>
      '$streetAddress, $landmark, $area, $city, $state';

  @override
  List<Object?> get props => [
        id,
        label,
        fullName,
        phoneNumber,
        state,
        city,
        area,
        streetAddress,
        landmark,
        isDefault,
      ];
}
