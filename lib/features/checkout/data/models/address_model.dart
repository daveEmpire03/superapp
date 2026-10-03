import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.label,
    required super.fullName,
    required super.phoneNumber,
    required super.state,
    required super.city,
    required super.area,
    required super.streetAddress,
    required super.landmark,
    super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String? ?? 'Home',
      fullName: json['fullName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      state: json['state'] as String? ?? 'Lagos',
      city: json['city'] as String? ?? 'Lagos',
      area: json['area'] as String? ?? 'Lekki',
      streetAddress: json['streetAddress'] as String? ?? '',
      landmark: json['landmark'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'state': state,
      'city': city,
      'area': area,
      'streetAddress': streetAddress,
      'landmark': landmark,
      'isDefault': isDefault,
    };
  }
}
