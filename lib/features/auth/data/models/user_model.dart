import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.role,
    required super.isEmailVerified,
    required super.isPhoneVerified,
    super.avatarUrl,
    super.walletBalance,
    super.loyaltyPoints,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final legacyFullName = json['fullName']?.toString().trim() ?? '';

    final legacyNameParts = legacyFullName.isEmpty
        ? <String>[]
        : legacyFullName
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList();

    final firstName = json['first_name']?.toString() ??
        (legacyNameParts.isNotEmpty ? legacyNameParts.first : '');

    final lastName = json['last_name']?.toString() ??
        (legacyNameParts.length > 1 ? legacyNameParts.skip(1).join(' ') : '');

    return UserModel(
      id: json['customer_id']?.toString() ?? json['id']?.toString() ?? '',
      firstName: firstName,
      lastName: lastName,
      email: json['email']?.toString() ?? '',
      phoneNumber:
          json['phone']?.toString() ?? json['phoneNumber']?.toString() ?? '',
      role: json['role']?.toString() ?? 'CUSTOMER',
      isEmailVerified: json['is_email_verified'] == true,
      isPhoneVerified: json['is_phone_verified'] == true,
      avatarUrl:
          json['avatar_url']?.toString() ?? json['avatarUrl']?.toString() ?? '',
      walletBalance: _toDouble(
        json['wallet_balance'] ?? json['walletBalance'],
      ),
      loyaltyPoints: _toInt(
        json['loyalty_points'] ?? json['loyaltyPoints'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phoneNumber,
      'role': role,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'avatar_url': avatarUrl,
      'wallet_balance': walletBalance,
      'loyalty_points': loyaltyPoints,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
